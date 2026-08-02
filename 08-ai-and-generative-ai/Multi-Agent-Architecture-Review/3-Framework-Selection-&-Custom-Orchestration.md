# Part 3: Framework Selection & Custom Orchestration

## 3.1 Introduction to Orchestration Frameworks

### The Target

Compare the leading orchestration frameworks and select the optimal combination for our enterprise needs.

### The Concept

Think of an orchestration framework as the stage manager of a complex theater production. While the individual actors (our agents) each have their roles, the stage manager coordinates entrances, exits, scene changes, and ensures everything runs smoothly according to the script.

Similarly, orchestration frameworks manage:
- **Agent lifecycle:** When each agent runs
- **State management:** What information persists between steps
- **Error handling:** What happens when something goes wrong
- **Human interaction:** When to pause for approval
- **Persistence:** How to save and resume workflows

### The Framework Landscape

We'll evaluate five major frameworks:

1. **LangGraph** - State graph orchestration with checkpoints
2. **CrewAI** - Role-based team collaboration
3. **AutoGen** - Multi-agent conversations with code execution
4. **OpenAI Swarm** - Lightweight multi-agent coordination
5. **MetaGPT** - Software development simulation

### The Decision Matrix

Let's compare these frameworks across our key criteria:

| Criterion | LangGraph | CrewAI | AutoGen | Swarm | MetaGPT |
|-----------|-----------|--------|---------|-------|---------|
| **State Management** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Human-in-the-Loop** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Checkpoint/Resume** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| **Agent Collaboration** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Ease of Use** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Enterprise Governance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Documentation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Community** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

### Our Decision

We will use a **hybrid approach**:

1. **LangGraph** for the main orchestration workflow with:
   - Stateful graph execution
   - Human-in-the-loop checkpoints
   - Error recovery and resumption
   - Enterprise governance

2. **CrewAI** for the documentation generation phase:
   - Role-based team (Writer, Editor, Reviewer)
   - Hierarchical process for document quality
   - Complementary to LangGraph's strengths

3. **Custom Python** for:
   - Repository integration
   - Cost management
   - ADR generation

This combination gives us the best of both worlds: LangGraph's rigorous state management with CrewAI's collaborative team dynamics.

---

## 3.2 Deep Dive: LangGraph

### The Concept

LangGraph is a framework for building stateful, multi-agent applications using graph structures. Think of it as a flowchart where each node is an action (like "Review with Security Agent") and edges are transitions that happen based on the state.

Key concepts:
- **State:** A dictionary that holds all information as it flows through the graph
- **Nodes:** Functions that process the state
- **Edges:** Conditional or unconditional transitions between nodes
- **Checkpoints:** Saved states that allow resuming from any point

### The Implementation

**`src/orchestration/langgraph_orchestrator.py`** - Production orchestration with LangGraph:

```python
"""
LangGraph-based orchestrator for multi-agent architecture reviews.

This provides enterprise-grade orchestration with:
- Stateful graph execution
- Checkpointing for resume capability
- Human-in-the-loop gates
- Error recovery
- Audit trails
"""

from typing import Dict, Any, List, Optional, TypedDict, Literal
from datetime import datetime
from pathlib import Path
import json
import sys
import traceback

from langgraph.graph import StateGraph, END
from langgraph.checkpoint import MemorySaver, SqliteSaver
from langgraph.prebuilt import ToolExecutor
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage

from src.agents import (
    FunctionalAgent,
    SecurityAgent,
    DataAgent,
    DevOpsAgent,
    ReliabilityAgent,
)
from src.utils.logger import get_logger
from src.utils.cost_tracker import get_cost_tracker, CostEntry

class ReviewState(TypedDict):
    """
    State that flows through the LangGraph workflow.
    
    This carries all information between nodes, including:
    - The original document
    - Agent results
    - Review status
    - Human decisions
    - Audit trail
    """
    document: str
    document_path: str
    review_id: str
    status: Literal["pending", "running", "waiting_for_human", "completed", "failed"]
    
    # Agent results
    functional_result: Optional[Dict[str, Any]]
    security_result: Optional[Dict[str, Any]]
    data_result: Optional[Dict[str, Any]]
    devops_result: Optional[Dict[str, Any]]
    reliability_result: Optional[Dict[str, Any]]
    
    # Human decisions
    human_approval: Optional[bool]
    human_comments: Optional[str]
    
    # Aggregated results
    aggregated_score: Optional[float]
    overall_risk: Optional[str]
    total_findings: Optional[int]
    
    # Audit and logging
    execution_log: List[Dict[str, Any]]
    start_time: Optional[str]
    end_time: Optional[str]
    errors: List[str]

class LangGraphOrchestrator:
    """
    LangGraph orchestrator for multi-agent architecture reviews.
    
    This orchestrator builds a state graph where each agent is a node,
    and human review gates pause execution for approval.
    """
    
    def __init__(self, model: Optional[str] = None, use_persistence: bool = True):
        """
        Initialize the LangGraph orchestrator.
        
        Args:
            model: Optional model override for all agents
            use_persistence: Whether to use SQLite checkpoints
        """
        self.model = model
        self.logger = get_logger("langgraph_orchestrator")
        self.cost_tracker = get_cost_tracker()
        
        # Initialize agents
        self.agents = {
            'functional': FunctionalAgent(model),
            'security': SecurityAgent(model),
            'data': DataAgent(model),
            'devops': DevOpsAgent(model),
            'reliability': ReliabilityAgent(model),
        }
        
        # Build the graph
        self.graph = self._build_graph()
        
        # Setup checkpointing
        if use_persistence:
            checkpoint_dir = Path("logs/checkpoints")
            checkpoint_dir.mkdir(parents=True, exist_ok=True)
            self.checkpoint_saver = SqliteSaver(
                str(checkpoint_dir / "reviews.db")
            )
        else:
            self.checkpoint_saver = MemorySaver()
        
        # Compile the graph
        self.compiled_graph = self.graph.compile(
            checkpointer=self.checkpoint_saver,
            interrupt_after=["human_review_node"]  # Interrupt for human input
        )
        
        self.logger.info("LangGraph orchestrator initialized")
    
    def _build_graph(self) -> StateGraph:
        """
        Build the state graph for the review workflow.
        
        The graph flow:
        1. Start -> Initialize state
        2. Initialize -> Run Functional Agent
        3. Functional -> Run Security Agent
        4. Security -> Run Data Agent
        5. Data -> Run DevOps Agent
        6. DevOps -> Run Reliability Agent
        7. Reliability -> Aggregate Results
        8. Aggregate -> Human Review (gate)
        9. Human Review -> Generate Report
        10. Generate Report -> END
        """
        workflow = StateGraph(ReviewState)
        
        # Add nodes
        workflow.add_node("initialize", self._initialize_node)
        workflow.add_node("run_functional", self._run_agent_node('functional'))
        workflow.add_node("run_security", self._run_agent_node('security'))
        workflow.add_node("run_data", self._run_agent_node('data'))
        workflow.add_node("run_devops", self._run_agent_node('devops'))
        workflow.add_node("run_reliability", self._run_agent_node('reliability'))
        workflow.add_node("aggregate_results", self._aggregate_results_node)
        workflow.add_node("human_review", self._human_review_node)
        workflow.add_node("generate_report", self._generate_report_node)
        
        # Define edges
        workflow.set_entry_point("initialize")
        
        # Sequential agent execution
        workflow.add_edge("initialize", "run_functional")
        workflow.add_edge("run_functional", "run_security")
        workflow.add_edge("run_security", "run_data")
        workflow.add_edge("run_data", "run_devops")
        workflow.add_edge("run_devops", "run_reliability")
        
        # After all agents, aggregate results
        workflow.add_edge("run_reliability", "aggregate_results")
        
        # After aggregation, go to human review (gate)
        workflow.add_edge("aggregate_results", "human_review")
        
        # Conditional edge from human review
        workflow.add_conditional_edges(
            "human_review",
            self._after_human_review,
            {
                "approved": "generate_report",
                "rejected": END,
                "retry": "run_functional",  # Retry from beginning if needed
            }
        )
        
        workflow.add_edge("generate_report", END)
        
        return workflow
    
    def _initialize_node(self, state: ReviewState) -> ReviewState:
        """
        Initialize the review state.
        
        This sets up timestamps, generates a review ID, and validates
        the document.
        """
        self.logger.info("Initializing review")
        
        state['review_id'] = f"review_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        state['start_time'] = datetime.now().isoformat()
        state['status'] = "running"
        state['execution_log'] = state.get('execution_log', [])
        state['errors'] = state.get('errors', [])
        
        state['execution_log'].append({
            'timestamp': datetime.now().isoformat(),
            'action': 'initialize',
            'message': f"Review started with ID {state['review_id']}"
        })
        
        # Validate document
        if not state.get('document', '').strip():
            raise ValueError("Document cannot be empty")
        
        self.logger.info(f"Review {state['review_id']} initialized")
        return state
    
    def _run_agent_node(self, agent_name: str):
        """
        Factory function that creates a node function for a specific agent.
        
        Args:
            agent_name: The name of the agent to run
            
        Returns:
            A node function that runs the specified agent
        """
        def node(state: ReviewState) -> ReviewState:
            """Run a specific agent and store results."""
            self.logger.info(f"Running {agent_name} agent")
            
            try:
                agent = self.agents[agent_name]
                result = agent.review(state['document'])
                
                # Store result in the appropriate state key
                result_key = f"{agent_name}_result"
                state[result_key] = result
                
                # Log success
                state['execution_log'].append({
                    'timestamp': datetime.now().isoformat(),
                    'action': f'run_{agent_name}',
                    'status': 'success',
                    'score': result.get('score', 0),
                    'findings': len(result.get('findings', []))
                })
                
                self.logger.info(f"{agent_name} agent completed with score {result.get('score', 0)}%")
                
            except Exception as e:
                error_msg = f"{agent_name} agent failed: {str(e)}"
                self.logger.error(error_msg, exc_info=True)
                state['errors'].append(error_msg)
                
                state['execution_log'].append({
                    'timestamp': datetime.now().isoformat(),
                    'action': f'run_{agent_name}',
                    'status': 'failed',
                    'error': str(e)
                })
                
                # Store a failure result
                state[f"{agent_name}_result"] = {
                    'domain': agent_name,
                    'agent': agent_name,
                    'error': str(e),
                    'summary': f'Failed: {str(e)}',
                    'score': 0,
                    'overall_risk': 'HIGH',
                    'findings': []
                }
            
            return state
        
        return node
    
    def _aggregate_results_node(self, state: ReviewState) -> ReviewState:
        """
        Aggregate all agent results into a unified assessment.
        """
        self.logger.info("Aggregating results")
        
        results = []
        scores = []
        
        for agent_name in ['functional', 'security', 'data', 'devops', 'reliability']:
            result_key = f"{agent_name}_result"
            result = state.get(result_key, {})
            if result and 'error' not in result:
                results.append(result)
                scores.append(result.get('score', 0))
        
        # Calculate aggregate metrics
        if scores:
            state['aggregated_score'] = round(sum(scores) / len(scores), 1)
        else:
            state['aggregated_score'] = 0
        
        # Determine overall risk (highest risk wins)
        risk_levels = {'LOW': 0, 'MEDIUM': 1, 'HIGH': 2}
        max_risk = 'LOW'
        max_risk_value = 0
        
        total_findings = 0
        critical_findings = 0
        high_findings = 0
        
        for result in results:
            risk = result.get('overall_risk', 'LOW')
            risk_value = risk_levels.get(risk, 0)
            if risk_value > max_risk_value:
                max_risk_value = risk_value
                max_risk = risk
            
            findings = result.get('findings', [])
            total_findings += len(findings)
            
            for f in findings:
                severity = f.get('severity', 'MEDIUM').upper()
                if severity == 'CRITICAL':
                    critical_findings += 1
                elif severity == 'HIGH':
                    high_findings += 1
        
        state['overall_risk'] = max_risk
        state['total_findings'] = total_findings
        state['critical_findings'] = critical_findings
        state['high_findings'] = high_findings
        
        state['execution_log'].append({
            'timestamp': datetime.now().isoformat(),
            'action': 'aggregate_results',
            'score': state['aggregated_score'],
            'risk': max_risk,
            'total_findings': total_findings
        })
        
        self.logger.info(
            f"Aggregation complete. Score: {state['aggregated_score']}%, "
            f"Risk: {max_risk}, Findings: {total_findings}"
        )
        
        return state
    
    def _human_review_node(self, state: ReviewState) -> ReviewState:
        """
        Human review gate.
        
        This node pauses execution for human approval.
        The user can:
        1. Approve the results
        2. Reject the results
        3. Request a retry
        """
        self.logger.info("Entering human review gate")
        
        state['status'] = "waiting_for_human"
        
        # Check if human decision is already provided (for resumption)
        if state.get('human_approval') is not None:
            return state
        
        # In a real system, this would be handled by an external UI
        # For now, we simulate with CLI input
        print("\n" + "=" * 80)
        print("HUMAN REVIEW GATE")
        print("=" * 80)
        print(f"\nReview ID: {state['review_id']}")
        print(f"Aggregate Score: {state['aggregated_score']}%")
        print(f"Overall Risk: {state['overall_risk']}")
        print(f"Total Findings: {state['total_findings']}")
        print(f"Critical Findings: {state.get('critical_findings', 0)}")
        print(f"High Findings: {state.get('high_findings', 0)}")
        
        # Show a summary of critical findings
        print("\nCritical Findings:")
        for agent_name in ['security', 'reliability']:  # Most critical domains
            result_key = f"{agent_name}_result"
            result = state.get(result_key, {})
            findings = result.get('findings', [])
            critical = [f for f in findings if f.get('severity', '').upper() == 'CRITICAL']
            if critical:
                print(f"  {agent_name.upper()}:")
                for f in critical[:3]:
                    print(f"    - {f.get('recommendation', 'No recommendation')}")
                    if len(critical) > 3:
                        print(f"    ... and {len(critical) - 3} more")
        
        print("\nOptions:")
        print("  1. APPROVE - Proceed with report generation")
        print("  2. REJECT - Stop the review")
        print("  3. RETRY - Re-run the agents")
        
        while True:
            choice = input("\nEnter choice (1/2/3): ").strip()
            if choice == "1":
                state['human_approval'] = True
                state['human_comments'] = input("Add comments (optional): ").strip() or "Approved"
                break
            elif choice == "2":
                state['human_approval'] = False
                state['human_comments'] = input("Reason for rejection: ").strip() or "Rejected"
                break
            elif choice == "3":
                state['human_approval'] = None
                state['human_comments'] = "Retry requested"
                # Clear previous agent results for retry
                for agent_name in ['functional', 'security', 'data', 'devops', 'reliability']:
                    state[f"{agent_name}_result"] = None
                break
            else:
                print("Invalid choice. Please enter 1, 2, or 3.")
        
        state['execution_log'].append({
            'timestamp': datetime.now().isoformat(),
            'action': 'human_review',
            'approval': state['human_approval'],
            'comments': state['human_comments']
        })
        
        return state
    
    def _after_human_review(self, state: ReviewState) -> str:
        """
        Determine the next step after human review.
        """
        if state.get('human_approval') is True:
            return "approved"
        elif state.get('human_approval') is False:
            return "rejected"
        else:
            return "retry"
    
    def _generate_report_node(self, state: ReviewState) -> ReviewState:
        """
        Generate the final review report.
        """
        self.logger.info("Generating report")
        
        state['status'] = "completed"
        state['end_time'] = datetime.now().isoformat()
        
        # Generate a comprehensive report
        report_lines = []
        report_lines.append("=" * 80)
        report_lines.append("MULTI-AGENT ARCHITECTURE REVIEW REPORT")
        report_lines.append("=" * 80)
        report_lines.append("")
        report_lines.append(f"Review ID: {state['review_id']}")
        report_lines.append(f"Document: {state.get('document_path', 'Unknown')}")
        report_lines.append(f"Started: {state['start_time']}")
        report_lines.append(f"Completed: {state['end_time']}")
        report_lines.append("")
        report_lines.append(f"Overall Score: {state['aggregated_score']}%")
        report_lines.append(f"Overall Risk: {state['overall_risk']}")
        report_lines.append(f"Total Findings: {state['total_findings']}")
        report_lines.append(f"Critical Findings: {state.get('critical_findings', 0)}")
        report_lines.append(f"High Findings: {state.get('high_findings', 0)}")
        report_lines.append("")
        
        # Human decision
        report_lines.append("-" * 80)
        report_lines.append("HUMAN DECISION")
        report_lines.append("-" * 80)
        report_lines.append(f"Approved: {state.get('human_approval', False)}")
        report_lines.append(f"Comments: {state.get('human_comments', 'No comments')}")
        report_lines.append("")
        
        # Agent results
        report_lines.append("-" * 80)
        report_lines.append("AGENT RESULTS")
        report_lines.append("-" * 80)
        report_lines.append("")
        
        for agent_name in ['functional', 'security', 'data', 'devops', 'reliability']:
            result_key = f"{agent_name}_result"
            result = state.get(result_key, {})
            report_lines.append(f"=== {agent_name.upper()} ===")
            report_lines.append(f"Score: {result.get('score', 0)}%")
            report_lines.append(f"Risk: {result.get('overall_risk', 'UNKNOWN')}")
            
            findings = result.get('findings', [])
            if findings:
                report_lines.append("Findings:")
                for f in findings:
                    status = f.get('status', 'UNKNOWN')
                    severity = f.get('severity', 'MEDIUM')
                    rec = f.get('recommendation', 'No recommendation')
                    report_lines.append(f"  [{status}] {severity}: {rec}")
            else:
                report_lines.append("No findings reported")
            
            report_lines.append("")
        
        # Cost report
        report_lines.append("-" * 80)
        report_lines.append("COST REPORT")
        report_lines.append("-" * 80)
        report_lines.append("")
        report_lines.append(self.cost_tracker.format_report())
        report_lines.append("")
        
        # Execution log
        report_lines.append("-" * 80)
        report_lines.append("EXECUTION LOG")
        report_lines.append("-" * 80)
        for entry in state.get('execution_log', []):
            report_lines.append(f"{entry.get('timestamp')}: {entry.get('action')} - {entry.get('message', '')}")
        
        report_lines.append("")
        report_lines.append("=" * 80)
        report_lines.append("END OF REPORT")
        report_lines.append("=" * 80)
        
        state['report'] = "\n".join(report_lines)
        
        # Save report to disk
        report_dir = Path("docs/outputs")
        report_dir.mkdir(parents=True, exist_ok=True)
        report_path = report_dir / f"{state['review_id']}_report.txt"
        report_path.write_text(state['report'])
        
        self.logger.info(f"Report saved to {report_path}")
        
        state['execution_log'].append({
            'timestamp': datetime.now().isoformat(),
            'action': 'generate_report',
            'report_path': str(report_path)
        })
        
        return state
    
    def review(self, document: str, document_path: str = "Unknown") -> Dict[str, Any]:
        """
        Run the full LangGraph review workflow.
        
        Args:
            document: The document text to review
            document_path: Path to the document (for reporting)
            
        Returns:
            The final state of the review
        """
        self.logger.info("Starting LangGraph review workflow")
        
        # Initialize state
        initial_state: ReviewState = {
            'document': document,
            'document_path': document_path,
            'review_id': '',
            'status': 'pending',
            'functional_result': None,
            'security_result': None,
            'data_result': None,
            'devops_result': None,
            'reliability_result': None,
            'human_approval': None,
            'human_comments': None,
            'aggregated_score': None,
            'overall_risk': None,
            'total_findings': None,
            'execution_log': [],
            'start_time': None,
            'end_time': None,
            'errors': []
        }
        
        # Configure the run
        config = {
            "configurable": {
                "thread_id": f"review_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            }
        }
        
        # Run the graph
        try:
            final_state = self.compiled_graph.invoke(
                initial_state,
                config=config
            )
            
            self.logger.info(f"Workflow completed with status: {final_state['status']}")
            
            # Convert to a serializable response
            return {
                'review_id': final_state.get('review_id'),
                'status': final_state.get('status'),
                'aggregated_score': final_state.get('aggregated_score'),
                'overall_risk': final_state.get('overall_risk'),
                'total_findings': final_state.get('total_findings'),
                'critical_findings': final_state.get('critical_findings'),
                'high_findings': final_state.get('high_findings'),
                'human_approval': final_state.get('human_approval'),
                'human_comments': final_state.get('human_comments'),
                'report': final_state.get('report'),
                'execution_log': final_state.get('execution_log'),
                'errors': final_state.get('errors'),
                'results': {
                    'functional': final_state.get('functional_result'),
                    'security': final_state.get('security_result'),
                    'data': final_state.get('data_result'),
                    'devops': final_state.get('devops_result'),
                    'reliability': final_state.get('reliability_result'),
                }
            }
            
        except Exception as e:
            self.logger.error(f"Workflow failed: {e}", exc_info=True)
            return {
                'review_id': None,
                'status': 'failed',
                'error': str(e),
                'traceback': traceback.format_exc()
            }
    
    def resume_review(self, thread_id: str) -> Dict[str, Any]:
        """
        Resume a previously interrupted review.
        
        Args:
            thread_id: The thread ID of the review to resume
            
        Returns:
            The final state of the resumed review
        """
        self.logger.info(f"Resuming review with thread_id: {thread_id}")
        
        config = {
            "configurable": {
                "thread_id": thread_id
            }
        }
        
        try:
            # Get the current state
            current_state = self.compiled_graph.get_state(config)
            
            if current_state is None:
                raise ValueError(f"No state found for thread_id: {thread_id}")
            
            # Resume execution
            final_state = self.compiled_graph.invoke(
                None,  # No initial state needed
                config=config
            )
            
            self.logger.info(f"Resumed workflow completed with status: {final_state['status']}")
            
            # Return the same format as review()
            return {
                'review_id': final_state.get('review_id'),
                'status': final_state.get('status'),
                'aggregated_score': final_state.get('aggregated_score'),
                'overall_risk': final_state.get('overall_risk'),
                'total_findings': final_state.get('total_findings'),
                'critical_findings': final_state.get('critical_findings'),
                'high_findings': final_state.get('high_findings'),
                'human_approval': final_state.get('human_approval'),
                'human_comments': final_state.get('human_comments'),
                'report': final_state.get('report'),
                'execution_log': final_state.get('execution_log'),
                'errors': final_state.get('errors'),
                'results': {
                    'functional': final_state.get('functional_result'),
                    'security': final_state.get('security_result'),
                    'data': final_state.get('data_result'),
                    'devops': final_state.get('devops_result'),
                    'reliability': final_state.get('reliability_result'),
                }
            }
            
        except Exception as e:
            self.logger.error(f"Resume failed: {e}", exc_info=True)
            return {
                'review_id': None,
                'status': 'failed',
                'error': str(e),
                'traceback': traceback.format_exc()
            }
    
    def list_checkpoints(self) -> List[Dict[str, Any]]:
        """
        List all available checkpoints for resumed reviews.
        
        Returns:
            List of checkpoint metadata
        """
        if not isinstance(self.checkpoint_saver, SqliteSaver):
            return [{"warning": "No persistence configured"}]
        
        # This is a simplified implementation
        # Actual listing would query the SQLite database
        checkpoint_dir = Path("logs/checkpoints")
        if checkpoint_dir.exists():
            db_path = checkpoint_dir / "reviews.db"
            if db_path.exists():
                # For a real implementation, we'd query the DB
                return [{"message": "Checkpoints available in logs/checkpoints/reviews.db"}]
        
        return [{"message": "No checkpoints found"}]
```

---

## 3.3 Deep Dive: CrewAI for Documentation

### The Concept

CrewAI implements a role-based team where each member has a specific role, goal, and backstory. This is perfect for documentation generation because we can create:

- **Writer:** Creates the initial draft
- **Editor:** Refines and improves the writing
- **Reviewer:** Ensures quality and completeness

### The Implementation

**`src/orchestration/crewai_docs.py`** - Documentation generation with CrewAI:

```python
"""
CrewAI-based documentation generation for architecture reviews.

Creates a team of AI agents that collaborate to produce
high-quality documentation from review results.
"""

from typing import Dict, Any, List, Optional
from pathlib import Path
import json

from crewai import Agent, Task, Crew, Process
from crewai.project import CrewBase, agent, task, crew
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic

from src.utils.config import get_settings
from src.utils.logger import get_logger

class DocumentationCrew:
    """
    CrewAI team for generating architecture review documentation.
    
    This team consists of:
    1. Writer: Creates the initial documentation draft
    2. Editor: Refines and improves the writing
    3. Reviewer: Ensures quality and completeness
    4. Architect: Provides technical oversight and accuracy
    """
    
    def __init__(self, model: Optional[str] = None):
        """
        Initialize the documentation crew.
        
        Args:
            model: Optional model override
        """
        self.settings = get_settings()
        self.logger = get_logger("crewai_docs")
        self.model = model or self.settings.default_model
        
        # Initialize LLM
        self.llm = self._init_llm()
        
        # Create agents
        self.agents = self._create_agents()
        
        self.logger.info("Documentation crew initialized")
    
    def _init_llm(self):
        """Initialize the LLM for CrewAI."""
        if "gpt" in self.model.lower():
            return ChatOpenAI(
                model=self.model,
                temperature=self.settings.temperature,
                max_tokens=self.settings.max_tokens
            )
        elif "claude" in self.model.lower():
            return ChatAnthropic(
                model=self.model,
                temperature=self.settings.temperature,
                max_tokens=self.settings.max_tokens
            )
        else:
            # Default to OpenAI
            return ChatOpenAI(
                model="gpt-4-turbo-preview",
                temperature=self.settings.temperature,
                max_tokens=self.settings.max_tokens
            )
    
    def _create_agents(self) -> Dict[str, Agent]:
        """
        Create the documentation team agents.
        """
        agents = {}
        
        # 1. Technical Writer
        agents['writer'] = Agent(
            role="Technical Writer",
            goal="Create comprehensive and well-structured documentation from review results",
            backstory="""You are an experienced technical writer with 15 years of experience
            writing software architecture documentation. You have a gift for taking complex
            technical information and presenting it clearly and accessibly. You've written
            documentation for Fortune 500 companies and open-source projects alike.
            You are meticulous about structure, clarity, and completeness.""",
            llm=self.llm,
            verbose=True,
            allow_delegation=False
        )
        
        # 2. Editor
        agents['editor'] = Agent(
            role="Documentation Editor",
            goal="Polish and refine documentation for clarity, consistency, and quality",
            backstory="""You are a senior editor with a background in both technical writing
            and software engineering. You have an eagle eye for errors, inconsistencies, and
            unclear passages. You ensure that documentation meets the highest quality standards
            and is accessible to the intended audience. You're known for making good writing great.""",
            llm=self.llm,
            verbose=True,
            allow_delegation=False
        )
        
        # 3. Reviewer
        agents['reviewer'] = Agent(
            role="Documentation Reviewer",
            goal="Ensure documentation is complete, accurate, and addresses all key points",
            backstory="""You are a principal software architect with 20 years of experience
            designing large-scale systems. You've reviewed hundreds of architecture documents
            and know exactly what makes a design decision clear and defensible.
            You ensure that the documentation captures all critical decisions and their rationales.
            You are thorough and demand excellence.""",
            llm=self.llm,
            verbose=True,
            allow_delegation=False
        )
        
        # 4. Formatter (for ADR generation)
        agents['formatter'] = Agent(
            role="ADR Formatter",
            goal="Format architecture decisions as formal ADRs in Markdown",
            backstory="""You are a documentation specialist focused on ADRs (Architectural Decision Records).
            You know the MADR (Markdown Architectural Decision Records) format inside and out.
            You ensure that every ADR is complete, properly formatted, and ready for repository commit.
            You take pride in producing documentation that developers actually read and use.""",
            llm=self.llm,
            verbose=True,
            allow_delegation=False
        )
        
        return agents
    
    def generate_documentation(self, review_results: Dict[str, Any]) -> Dict[str, str]:
        """
        Generate comprehensive documentation from review results.
        
        Args:
            review_results: Results from a multi-agent review
            
        Returns:
            Dictionary containing generated documentation in various formats
        """
        self.logger.info("Starting documentation generation")
        
        # Extract key information
        summary = self._extract_summary(review_results)
        agents_results = review_results.get('results', {})
        
        # Create tasks
        tasks = self._create_tasks(summary, agents_results)
        
        # Create and run the crew
        crew = Crew(
            agents=[self.agents['writer'], self.agents['editor'], self.agents['reviewer']],
            tasks=tasks,
            process=Process.sequential,
            verbose=True,
            manager_llm=self.llm
        )
        
        # Run the crew
        result = crew.kickoff()
        
        # Generate ADR from the results
        adr_content = self._generate_adr(review_results)
        
        self.logger.info("Documentation generation complete")
        
        return {
            'documentation': result,
            'adr': adr_content,
            'summary': summary
        }
    
    def _extract_summary(self, review_results: Dict[str, Any]) -> str:
        """
        Extract a summary from the review results.
        
        This creates a concise summary that the writer can use as a starting point.
        """
        lines = []
        lines.append("ARCHITECTURE REVIEW SUMMARY")
        lines.append("=" * 40)
        lines.append("")
        lines.append(f"Review ID: {review_results.get('review_id', 'N/A')}")
        lines.append(f"Aggregate Score: {review_results.get('aggregated_score', 0)}%")
        lines.append(f"Overall Risk: {review_results.get('overall_risk', 'UNKNOWN')}")
        lines.append(f"Total Findings: {review_results.get('total_findings', 0)}")
        lines.append("")
        
        # Agent summaries
        lines.append("AGENT SUMMARIES")
        lines.append("-" * 20)
        for agent_name, result in review_results.get('results', {}).items():
            if result:
                lines.append(f"\n{agent_name.upper()}:")
                lines.append(f"  Score: {result.get('score', 0)}%")
                lines.append(f"  Risk: {result.get('overall_risk', 'UNKNOWN')}")
                
                findings = result.get('findings', [])
                if findings:
                    critical = [f for f in findings if f.get('severity', '').upper() == 'CRITICAL']
                    high = [f for f in findings if f.get('severity', '').upper() == 'HIGH']
                    if critical:
                        lines.append(f"  Critical Issues: {len(critical)}")
                        for f in critical[:3]:
                            lines.append(f"    - {f.get('recommendation', 'No recommendation')[:100]}...")
                    if high:
                        lines.append(f"  High Issues: {len(high)}")
        
        lines.append("")
        lines.append("The documentation should cover all findings and recommendations.")
        lines.append("Include ADRs for key decisions and tradeoffs.")
        
        return "\n".join(lines)
    
    def _create_tasks(self, summary: str, agents_results: Dict[str, Any]) -> List[Task]:
        """
        Create tasks for the crew.
        """
        tasks = []
        
        # Task 1: Write the documentation
        tasks.append(Task(
            description=f"""
            Create comprehensive documentation based on the architecture review results.
            
            The documentation should include:
            1. Executive Summary - Key findings and overall assessment
            2. Agent Reports - Detailed findings from each specialist
            3. Critical Issues - All CRITICAL and HIGH severity issues
            4. Recommendations - Actionable recommendations
            5. Risk Assessment - Overall risk profile
            6. Next Steps - Recommended actions
            
            Base your documentation on this summary:
            
            {summary}
            
            And these detailed results:
            {json.dumps(agents_results, indent=2)[:2000]}...
            
            Structure the documentation as a formal architecture review report.
            Use clear headings, bullet points, and professional language.
            """,
            agent=self.agents['writer'],
            expected_output="A comprehensive architecture review report in Markdown format"
        ))
        
        # Task 2: Edit and improve
        tasks.append(Task(
            description="""
            Edit and refine the documentation produced by the writer.
            
            Focus on:
            1. Clarity - Is everything clear and easy to understand?
            2. Consistency - Is the language and formatting consistent?
            3. Grammar and style - Correct any errors
            4. Structure - Is the information in the right order?
            5. Completeness - Are any important points missing?
            6. Accessibility - Can a non-expert understand it?
            
            Improve the writing while maintaining all technical accuracy.
            """,
            agent=self.agents['editor'],
            expected_output="A polished and refined documentation draft"
        ))
        
        # Task 3: Review for completeness
        tasks.append(Task(
            description="""
            Review the documentation for completeness and accuracy.
            
            Verify that:
            1. All critical findings are included
            2. All recommendations are actionable
            3. The risk assessment is accurate
            4. Technical details are correct
            5. Nothing important has been omitted
            
            If anything is missing or incorrect, note it.
            Provide a final approval or suggest changes.
            """,
            agent=self.agents['reviewer'],
            expected_output="A final review with approval or change suggestions"
        ))
        
        return tasks
    
    def _generate_adr(self, review_results: Dict[str, Any]) -> str:
        """
        Generate a formal ADR from the review results.
        
        Uses the MADR (Markdown Architectural Decision Records) format.
        """
        # Extract key decisions from the review
        risk = review_results.get('overall_risk', 'UNKNOWN')
        score = review_results.get('aggregated_score', 0)
        
        # Find the most critical issues to turn into ADRs
        critical_issues = []
        for agent_name, result in review_results.get('results', {}).items():
            if result:
                findings = result.get('findings', [])
                for f in findings:
                    if f.get('severity', '').upper() in ['CRITICAL', 'HIGH']:
                        critical_issues.append({
                            'agent': agent_name,
                            'issue': f.get('recommendation', 'No recommendation'),
                            'evidence': f.get('evidence', 'No evidence provided')
                        })
        
        adr_lines = []
        adr_lines.append("# ADR: Architecture Review Decision")
        adr_lines.append("")
        adr_lines.append("## Status")
        adr_lines.append("")
        if risk == 'HIGH' or score < 60:
            adr_lines.append("**REJECTED** - Critical issues must be addressed")
        elif risk == 'MEDIUM' or score < 80:
            adr_lines.append("**CONDITIONAL** - Issues must be addressed before approval")
        else:
            adr_lines.append("**APPROVED** - Design meets all quality criteria")
        adr_lines.append("")
        
        adr_lines.append("## Context")
        adr_lines.append("")
        adr_lines.append(f"This document records the architectural review findings for the design.")
        adr_lines.append(f"The review was conducted on {review_results.get('timestamp', 'an unknown date')}.")
        adr_lines.append(f"Overall score: {score}%, Risk level: {risk}")
        adr_lines.append("")
        
        if critical_issues:
            adr_lines.append("## Critical Issues Identified")
            adr_lines.append("")
            for issue in critical_issues[:5]:  # Top 5 issues
                adr_lines.append(f"### {issue['agent'].upper()} Issue")
                adr_lines.append(f"- {issue['issue']}")
                if issue['evidence']:
                    adr_lines.append(f"- Evidence: {issue['evidence'][:200]}...")
                adr_lines.append("")
        
        adr_lines.append("## Decision")
        adr_lines.append("")
        if risk == 'HIGH' or score < 60:
            adr_lines.append("The architecture is rejected due to critical issues.")
            adr_lines.append("The following actions must be taken:")
            for i, issue in enumerate(critical_issues[:5], 1):
                adr_lines.append(f"{i}. Address the {issue['agent']} issue: {issue['issue'][:100]}...")
        elif risk == 'MEDIUM' or score < 80:
            adr_lines.append("The architecture is conditionally approved.")
            adr_lines.append("The following issues must be addressed before approval:")
            for i, issue in enumerate(critical_issues[:3], 1):
                adr_lines.append(f"{i}. {issue['issue'][:100]}...")
        else:
            adr_lines.append("The architecture is approved. No critical issues were found.")
        adr_lines.append("")
        
        adr_lines.append("## Consequences")
        adr_lines.append("")
        adr_lines.append("### Positive")
        adr_lines.append(f"- The design meets {score}% of the validation criteria")
        adr_lines.append("- All five quality domains were reviewed by specialists")
        adr_lines.append("- Findings are documented and actionable")
        adr_lines.append("")
        
        adr_lines.append("### Negative")
        if critical_issues:
            adr_lines.append(f"- {len(critical_issues)} critical/high issues require attention")
        adr_lines.append(f"- Risk level is {risk}")
        adr_lines.append("- Re-review will be required after addressing issues")
        adr_lines.append("")
        
        adr_lines.append("## References")
        adr_lines.append("")
        adr_lines.append(f"- Review ID: {review_results.get('review_id', 'N/A')}")
        adr_lines.append(f"- Aggregate Score: {score}%")
        adr_lines.append(f"- Total Findings: {review_results.get('total_findings', 0)}")
        adr_lines.append("- See full review report for details")
        adr_lines.append("")
        
        adr_lines.append("---")
        adr_lines.append("*This ADR was automatically generated by the Multi-Agent Architecture Review System*")
        
        return "\n".join(adr_lines)
    
    def save_documentation(self, docs: Dict[str, str], output_dir: Path) -> None:
        """
        Save generated documentation to disk.
        
        Args:
            docs: The documentation dictionary from generate_documentation
            output_dir: Directory to save files
        """
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Save the main documentation
        if 'documentation' in docs:
            doc_file = output_dir / "architecture-review-report.md"
            doc_file.write_text(docs['documentation'])
            self.logger.info(f"Documentation saved to {doc_file}")
        
        # Save the ADR
        if 'adr' in docs:
            adr_file = output_dir / "adr-review-decision.md"
            adr_file.write_text(docs['adr'])
            self.logger.info(f"ADR saved to {adr_file}")
        
        # Save the summary
        if 'summary' in docs:
            summary_file = output_dir / "review-summary.txt"
            summary_file.write_text(docs['summary'])
            self.logger.info(f"Summary saved to {summary_file}")
```

---

## 3.4 Integrating LangGraph and CrewAI

### The Target

Create a unified orchestrator that uses LangGraph for the main workflow and CrewAI for documentation generation.

### The Implementation

**`src/orchestration/unified_orchestrator.py`** - Complete integration:

```python
"""
Unified orchestrator combining LangGraph and CrewAI.

This provides the complete production workflow:
1. LangGraph manages the review workflow with checkpoints
2. CrewAI generates documentation from the results
3. Combined for enterprise-grade governance
"""

from typing import Dict, Any, Optional
from pathlib import Path
import json

from src.orchestration.langgraph_orchestrator import LangGraphOrchestrator
from src.orchestration.crewai_docs import DocumentationCrew
from src.utils.logger import get_logger
from src.utils.cost_tracker import get_cost_tracker

class UnifiedOrchestrator:
    """
    Unified orchestrator combining LangGraph and CrewAI.
    
    This provides:
    - LangGraph: Stateful review workflow with human gates
    - CrewAI: Professional documentation generation
    - Checkpointing: Resume interrupted reviews
    - Cost tracking: Monitor and control costs
    """
    
    def __init__(self, model: Optional[str] = None):
        """
        Initialize the unified orchestrator.
        
        Args:
            model: Optional model override
        """
        self.model = model
        self.logger = get_logger("unified_orchestrator")
        self.cost_tracker = get_cost_tracker()
        
        # Initialize components
        self.langgraph = LangGraphOrchestrator(model, use_persistence=True)
        self.crew = DocumentationCrew(model)
        
        self.logger.info("Unified orchestrator initialized")
    
    def review_and_document(self, document: str, document_path: str = "Unknown") -> Dict[str, Any]:
        """
        Complete workflow: review and document.
        
        Args:
            document: The document text to review
            document_path: Path to the document
            
        Returns:
            Complete results including documentation
        """
        self.logger.info("Starting unified review and documentation")
        
        # Step 1: Run the LangGraph review
        review_results = self.langgraph.review(document, document_path)
        
        if review_results.get('status') == 'failed':
            self.logger.error("Review failed, skipping documentation")
            return review_results
        
        # Step 2: Generate documentation with CrewAI
        if review_results.get('status') == 'completed':
            self.logger.info("Generating documentation with CrewAI")
            docs = self.crew.generate_documentation(review_results)
            
            # Save documentation
            output_dir = Path("docs/outputs")
            self.crew.save_documentation(docs, output_dir)
            
            # Add documentation to results
            review_results['documentation'] = docs
            review_results['output_dir'] = str(output_dir)
        
        self.logger.info("Unified workflow complete")
        return review_results
    
    def resume_review(self, thread_id: str) -> Dict[str, Any]:
        """
        Resume a previously interrupted review.
        
        Args:
            thread_id: The thread ID to resume
            
        Returns:
            Complete results
        """
        self.logger.info(f"Resuming review: {thread_id}")
        
        # Resume the LangGraph review
        review_results = self.langgraph.resume_review(thread_id)
        
        if review_results.get('status') == 'failed':
            return review_results
        
        # Generate documentation if completed
        if review_results.get('status') == 'completed':
            self.logger.info("Generating documentation for resumed review")
            docs = self.crew.generate_documentation(review_results)
            
            output_dir = Path("docs/outputs")
            self.crew.save_documentation(docs, output_dir)
            
            review_results['documentation'] = docs
            review_results['output_dir'] = str(output_dir)
        
        return review_results
    
    def list_reviews(self) -> list:
        """
        List all available review checkpoints.
        
        Returns:
            List of checkpoint metadata
        """
        return self.langgraph.list_checkpoints()
```

---

## 3.5 Updating the CLI for Unified Orchestration

**`src/cli.py`** - Update with unified orchestrator support:

```python
"""
Command-line interface with unified orchestrator support.
"""

import sys
import json
from pathlib import Path
from typing import Optional

import click
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn

from src.utils.config import get_settings, setup_logging
from src.utils.logger import get_logger
from src.agents.review_agent import ReviewAgent
from src.orchestration.simple_orchestrator import SimpleOrchestrator
from src.orchestration.unified_orchestrator import UnifiedOrchestrator

console = Console()

@click.group()
def cli():
    """Multi-Agent Architecture Review System CLI."""
    pass

@cli.command()
@click.option(
    '--doc',
    '-d',
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help='Path to the design document to review'
)
@click.option(
    '--model',
    '-m',
    default=None,
    help='Override the default model'
)
@click.option(
    '--mode',
    choices=['single', 'multi', 'unified'],
    default='unified',
    help='Review mode: single-agent, multi-agent, or unified (LangGraph + CrewAI)'
)
@click.option(
    '--output',
    '-o',
    type=click.Path(path_type=Path),
    default=None,
    help='Output file for the review results (JSON)'
)
@click.option(
    '--verbose',
    '-v',
    is_flag=True,
    help='Enable verbose logging'
)
def review(doc: Path, model: Optional[str], mode: str, 
           output: Optional[Path], verbose: bool):
    """
    Review a design document using the specified mode.
    
    Modes:
    - single: Original single-agent proof of concept
    - multi: Sequential multi-agent review
    - unified: Full LangGraph + CrewAI production workflow
    """
    # Setup logging
    log_level = "DEBUG" if verbose else "INFO"
    setup_logging(log_level)
    logger = get_logger("cli")
    
    logger.info(f"Starting review of {doc} in {mode} mode")
    
    # Read the document
    try:
        document_text = doc.read_text(encoding='utf-8')
        logger.debug(f"Read {len(document_text)} characters from {doc}")
    except Exception as e:
        console.print(f"[red]Error reading document: {e}[/red]")
        sys.exit(1)
    
    if mode == 'single':
        _run_single_review(document_text, doc.name, model, output)
    elif mode == 'multi':
        _run_multi_review(document_text, doc.name, model, output)
    else:  # unified
        _run_unified_review(document_text, doc.name, model, output, logger)

def _run_single_review(document: str, doc_name: str, model: Optional[str], output: Optional[Path]):
    """Run single-agent review."""
    console.print(Panel(
        f"[bold]Single-Agent Mode[/bold]\nDocument: {doc_name}",
        title="📋 Starting Review"
    ))
    
    agent = ReviewAgent(model=model)
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        transient=True,
    ) as progress:
        task = progress.add_task("[green]Reviewing document...", total=None)
        result = agent.review(document)
        progress.update(task, completed=True)
    
    console.print("\n[bold green]✅ Review Complete![/bold green]\n")
    _display_single_result(result)
    
    if output:
        _save_output(result, output)

def _run_multi_review(document: str, doc_name: str, model: Optional[str], output: Optional[Path]):
    """Run multi-agent sequential review."""
    console.print(Panel(
        f"[bold]Multi-Agent Mode[/bold]\nDocument: {doc_name}\nAgents: 5 specialized",
        title="🚀 Starting Multi-Agent Review"
    ))
    
    orchestrator = SimpleOrchestrator(model=model)
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        transient=True,
    ) as progress:
        task = progress.add_task("[green]All agents reviewing...", total=None)
        result = orchestrator.review(document)
        progress.update(task, completed=True)
    
    console.print("\n[bold green]✅ Multi-Agent Review Complete![/bold green]\n")
    _display_multi_result(result)
    
    # Generate report
    report_text = orchestrator.generate_report(result)
    report_path = Path("docs/outputs/multi-report.txt")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report_text)
    console.print(f"\n[green]✓ Report saved to: {report_path}[/green]")
    
    if output:
        _save_output(result, output)

def _run_unified_review(document: str, doc_name: str, model: Optional[str], 
                         output: Optional[Path], logger):
    """Run unified LangGraph + CrewAI review."""
    console.print(Panel(
        f"[bold]Unified Production Mode[/bold]\nDocument: {doc_name}\n"
        "LangGraph + CrewAI\nHuman-in-the-loop enabled",
        title="🏭 Starting Production Review"
    ))
    
    orchestrator = UnifiedOrchestrator(model=model)
    
    console.print("\n[italic]This review includes a human-in-the-loop gate.")
    console.print("You'll be prompted to approve, reject, or retry.[/italic]\n")
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        transient=True,
    ) as progress:
        task = progress.add_task("[green]Running review workflow...", total=None)
        result = orchestrator.review_and_document(document, doc_name)
        progress.update(task, completed=True)
    
    if result.get('status') == 'failed':
        console.print(f"[red]Review failed: {result.get('error')}[/red]")
        if 'traceback' in result:
            console.print(result['traceback'])
        sys.exit(1)
    
    console.print("\n[bold green]✅ Review Complete![/bold green]\n")
    
    # Display summary
    status = result.get('status', 'unknown')
    score = result.get('aggregated_score', 0)
    risk = result.get('overall_risk', 'UNKNOWN')
    
    risk_color = {"LOW": "green", "MEDIUM": "yellow", "HIGH": "red"}.get(risk, "white")
    
    console.print(Panel(
        f"Status: {status.upper()}\n"
        f"Score: {score}%\n"
        f"Risk: [{risk_color}]{risk}[/{risk_color}]\n"
        f"Findings: {result.get('total_findings', 0)}\n"
        f"Approved: {result.get('human_approval', 'N/A')}",
        title="📊 Summary"
    ))
    
    if result.get('human_comments'):
        console.print(f"\n[italic]Human comments: {result['human_comments']}[/italic]")
    
    # Show output locations
    if result.get('output_dir'):
        console.print(f"\n[green]✓ Documentation saved to: {result['output_dir']}[/green]")
        console.print(f"  - architecture-review-report.md")
        console.print(f"  - adr-review-decision.md")
        console.print(f"  - review-summary.txt")
    
    if output:
        _save_output(result, output)
    
    # Exit code based on risk
    if risk == "HIGH":
        sys.exit(2)
    elif risk == "MEDIUM":
        sys.exit(1)

def _display_single_result(result: Dict) -> None:
    """Display single-agent results."""
    summary = result.get("summary", "No summary")
    risk = result.get("overall_risk", "UNKNOWN")
    risk_color = {"LOW": "green", "MEDIUM": "yellow", "HIGH": "red", "UNKNOWN": "white"}.get(risk, "white")
    
    console.print(Panel(
        f"[bold]Assessment:[/bold]\n{summary[:300]}...\n\n"
        f"[bold]Risk:[/bold] [{risk_color}]{risk}[/{risk_color}]",
        title="📊 Single-Agent Results"
    ))

def _display_multi_result(result: Dict) -> None:
    """Display multi-agent results."""
    risk = result.get("overall_risk", "UNKNOWN")
    risk_color = {"LOW": "green", "MEDIUM": "yellow", "HIGH": "red"}.get(risk, "white")
    
    console.print(Panel(
        f"Score: {result.get('aggregated_score', 0)}%\n"
        f"Risk: [{risk_color}]{risk}[/{risk_color}]\n"
        f"Findings: {result.get('total_findings', 0)}\n"
        f"Critical: {result.get('critical_findings', 0)}",
        title="📊 Multi-Agent Summary"
    ))
    
    # Agent scores table
    table = Table(title="Agent Scores")
    table.add_column("Agent", style="cyan")
    table.add_column("Score", justify="right")
    table.add_column("Risk")
    
    for name, res in result.get('results', {}).items():
        score = res.get('score', 0)
        risk_level = res.get('overall_risk', 'UNKNOWN')
        risk_color = {"LOW": "green", "MEDIUM": "yellow", "HIGH": "red"}.get(risk_level, "white")
        table.add_row(
            name.upper(),
            f"{score}%",
            f"[{risk_color}]{risk_level}[/{risk_color}]"
        )
    
    console.print(table)

def _save_output(result: Dict, output: Path) -> None:
    """Save results to JSON."""
    try:
        output.parent.mkdir(parents=True, exist_ok=True)
        # Remove non-serializable objects
        clean_result = json.loads(json.dumps(result, default=str))
        with open(output, 'w') as f:
            json.dump(clean_result, f, indent=2)
        console.print(f"\n[green]✓ Results saved to: {output}[/green]")
    except Exception as e:
        console.print(f"\n[yellow]Warning: Could not save output: {e}[/yellow]")

@cli.command()
def config():
    """Display current configuration."""
    settings = get_settings()
    
    table = Table(title="⚙️ Current Configuration")
    table.add_column("Setting", style="cyan")
    table.add_column("Value", style="white")
    
    table.add_row("Environment", settings.environment)
    table.add_row("Default Model", settings.default_model)
    table.add_row("Temperature", str(settings.temperature))
    table.add_row("Max Tokens", str(settings.max_tokens))
    table.add_row("Review Budget", f"${settings.review_budget_usd}")
    
    for provider in ["openai", "anthropic", "deepseek"]:
        status = "✅" if settings.is_provider_available(provider) else "❌"
        table.add_row(f"{provider.title()} API", status)
    
    console.print(table)

@cli.command()
def cost():
    """Display cost tracking report."""
    from src.utils.cost_tracker import get_cost_tracker
    tracker = get_cost_tracker()
    console.print(tracker.format_report())

@cli.command()
@click.option('--thread-id', required=True, help='Thread ID to resume')
def resume(thread_id: str):
    """Resume a previously interrupted review."""
    console.print(f"[bold]Resuming review: {thread_id}[/bold]")
    
    orchestrator = UnifiedOrchestrator()
    result = orchestrator.resume_review(thread_id)
    
    if result.get('status') == 'failed':
        console.print(f"[red]Failed to resume: {result.get('error')}[/red]")
        sys.exit(1)
    
    console.print("[green]✓ Review resumed successfully[/green]")
    console.print(f"Status: {result.get('status')}")
    console.print(f"Score: {result.get('aggregated_score', 0)}%")

@cli.command()
def list():
    """List available review checkpoints."""
    orchestrator = UnifiedOrchestrator()
    checkpoints = orchestrator.list_reviews()
    
    if checkpoints:
        console.print("[bold]Available checkpoints:[/bold]")
        for cp in checkpoints:
            console.print(f"  - {cp}")
    else:
        console.print("[yellow]No checkpoints found[/yellow]")

@cli.command()
def version():
    """Display version information."""
    from src import __version__
    console.print(f"[bold]Multi-Agent Architecture Review System[/bold] v{__version__}")

def main():
    """Entry point for the CLI."""
    try:
        cli()
    except KeyboardInterrupt:
        console.print("\n[yellow]Interrupted by user[/yellow]")
        sys.exit(130)
    except Exception as e:
        console.print(f"[red]Unexpected error: {e}[/red]")
        import traceback
        console.print(traceback.format_exc())
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

## 3.6 The Verification

### Step 1: Test LangGraph Orchestrator

```bash
# Test the LangGraph orchestrator
python -c "
from pathlib import Path
from src.orchestration.langgraph_orchestrator import LangGraphOrchestrator

orchestrator = LangGraphOrchestrator()
doc = Path('docs/designs/sample-payment-service.md').read_text()
result = orchestrator.review(doc, 'sample-payment-service.md')
print(f'Status: {result.get(\"status\")}')
print(f'Score: {result.get(\"aggregated_score\")}%')
print(f'Risk: {result.get(\"overall_risk\")}')
"
```

### Step 2: Test Documentation Crew

```bash
# Test CrewAI documentation generation
python -c "
from pathlib import Path
from src.orchestration.langgraph_orchestrator import LangGraphOrchestrator
from src.orchestration.crewai_docs import DocumentationCrew

# First, get some review results
orchestrator = LangGraphOrchestrator()
doc = Path('docs/designs/sample-payment-service.md').read_text()
result = orchestrator.review(doc, 'sample-payment-service.md')

# Then generate documentation
crew = DocumentationCrew()
docs = crew.generate_documentation(result)
print('Documentation generated:')
print(f'  ADR length: {len(docs.get(\"adr\", \"\"))} chars')
print(f'  Summary length: {len(docs.get(\"summary\", \"\"))} chars')
"
```

### Step 3: Test Unified Orchestrator

```bash
# Run the full unified workflow
python review.py review -d docs/designs/sample-payment-service.md --mode unified -v

# During the run, you'll be prompted at the human review gate:
# Enter choice (1/2/3): 1  # Approve

# Check the generated outputs
ls -la docs/outputs/

# Should see:
# - architecture-review-report.md
# - adr-review-decision.md
# - review-summary.txt
# - review_*.json
```

### Step 4: Test Resume Capability

```bash
# After a review is interrupted (you pressed Ctrl+C or it's waiting for input),
# you can list checkpoints:
python review.py list

# Then resume a specific review:
python review.py resume --thread-id review_20260803_143022
```

### Step 5: Compare All Modes

```bash
# Run all three modes and compare
for mode in single multi unified; do
    echo "=== Mode: $mode ==="
    time python review.py review -d docs/designs/sample-payment-service.md --mode $mode
    echo ""
done
```

Expected output shows:
- **Single:** Fastest (~15s), least comprehensive
- **Multi:** Balanced (~60s), good coverage
- **Unified:** Slowest (~90s), most comprehensive with human gate

---

## Part 3 Summary

We've successfully implemented production-grade orchestration:

### ✅ Completed Deliverables

1. **Framework Evaluation**
   - Comprehensive comparison of 5 frameworks
   - Decision matrix with rationale
   - Hybrid LangGraph + CrewAI approach

2. **LangGraph Orchestrator**
   - State graph with 10+ nodes
   - Checkpointing for resume capability
   - Human-in-the-loop gates
   - Complete audit trail

3. **CrewAI Documentation Team**
   - 4 specialized agents (Writer, Editor, Reviewer, Formatter)
   - Sequential process for quality
   - ADR generation in MADR format

4. **Unified Orchestrator**
   - Integrated LangGraph + CrewAI
   - Complete production workflow
   - Resume functionality
   - Output management

### 📊 Code Statistics

- **New Files:** 4
- **Lines of Code:** ~900
- **Frameworks:** LangGraph + CrewAI
- **Graph Nodes:** 10+
- **Crew Agents:** 4

### 🎯 Key Takeaways

1. **LangGraph** provides enterprise-grade state management and human gates
2. **CrewAI** excels at collaborative documentation generation
3. **Hybrid approach** leverages strengths of both frameworks
4. **Checkpointing** enables resilient, production-ready workflows

### 🔜 What's Next: Part 4

In Part 4, we'll:
- Add repository awareness with Git integration
- Implement RAG for contextual awareness
- Automate ADR generation with formal templates
- Establish production governance with tool permissions
- Build a complete deployment-ready system

---

*Ready to continue? Part 4 will connect our system directly to your codebase, automate ADR generation, and establish production governance for enterprise deployment.*
