# Comprehensive Quiz and Test Bank

## Complete Assessment Package with Answer Keys

---

## TABLE OF CONTENTS

1. **Part 0: Introduction** - Basic Concepts Quiz
2. **Phase 1: Foundations** - Module Quizzes + Final Exam
3. **Phase 2: Modern Dependency Risk Analysis** - Module Quizzes + Final Exam
4. **Phase 3: Async Execution & Orchestration** - Module Quizzes + Final Exam
5. **Phase 4: AI-Augmented Security** - Module Quizzes + Final Exam
6. **Primers** - Comprehensive Quizzes
7. **Final Comprehensive Exam** - 100 Questions
8. **Answer Keys** - All Sections

---

## PART 0: INTRODUCTION - BASIC CONCEPTS QUIZ

### Section 0.1: Multiple Choice (10 Questions)

**1. What percentage of modern applications are assembled from open-source dependencies?**
- [ ] 50%
- [ ] 70%
- [ ] 90%
- [ ] 99%

**2. What is the primary limitation of traditional SCA tools?**
- [ ] They are too expensive
- [ ] They only check known vulnerabilities (CVEs)
- [ ] They don't work with JavaScript
- [ ] They require manual operation

**3. Which of the following is NOT a typical attack vector for malicious packages?**
- [ ] Executing unauthorized install scripts
- [ ] Collecting environment variables
- [ ] Opening outbound network connections
- [ ] Writing clean, well-documented code

**4. What does SCA stand for?**
- [ ] Secure Code Analysis
- [ ] Software Composition Analysis
- [ ] System Configuration Assessment
- [ ] Security Compliance Audit

**5. Which of the following is a modern supply chain attack type?**
- [ ] SQL Injection
- [ ] Typosquatting
- [ ] Cross-Site Scripting
- [ ] Buffer Overflow

**6. What is the primary benefit of using open-source dependencies?**
- [ ] Better security
- [ ] Faster development
- [ ] Lower maintenance
- [ ] Fewer bugs

**7. Which phase of the tutorial focuses on building the security scanner?**
- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3
- [ ] Phase 4

**8. What is the role of AI in the security system built in this series?**
- [ ] To make all security decisions
- [ ] To replace human security teams
- [ ] To augment human judgment
- [ ] To eliminate the need for policies

**9. Which of the following is a prerequisite for this tutorial series?**
- [ ] Advanced security experience
- [ ] AI/ML expertise
- [ ] DevOps experience
- [ ] Basic JavaScript/Node.js knowledge

**10. What is the ultimate architecture goal of this series?**
- [ ] A simple vulnerability scanner
- [ ] A production-ready security pipeline with AI augmentation
- [ ] A static code analysis tool
- [ ] A package manager replacement

### Section 0.2: True/False (5 Questions)

**11. The tutorial assumes prior security experience.**
- [ ] True
- [ ] False

**12. Traditional CVE-based scanning is sufficient for modern security needs.**
- [ ] True
- [ ] False

**13. Modern attacks often have no published CVEs.**
- [ ] True
- [ ] False

**14. The tutorial only covers npm packages.**
- [ ] True
- [ ] False

**15. AI should never serve as the authoritative decision-maker for security enforcement.**
- [ ] True
- [ ] False

### Section 0.3: Fill in the Blank (5 Questions)

**16.** Today, over __________% of applications are assembled from third-party dependencies.

**17.** Next-generation SCA platforms analyze package __________, capabilities, and execution context.

**18.** The tutorial explores the evolution of SCA by comparing __________ and __________.

**19.** LLMs should operate within well-defined __________, producing structured outputs.

**20.** In a secure software supply chain, AI enhances human judgment but does not replace __________ security controls.

---

## PHASE 1: FOUNDATIONS - MODULE QUIZZES

### Module 1.1: JavaScript Execution Model

#### Section 1.1.1: Multiple Choice (8 Questions)

**21. What is the call stack?**
- [ ] A region of memory for storing objects
- [ ] A LIFO structure that tracks function execution
- [ ] A queue for asynchronous operations
- [ ] A cache for frequently used functions

**22. Which of the following has the HIGHEST priority in the event loop?**
- [ ] setTimeout
- [ ] Promise.then
- [ ] process.nextTick
- [ ] I/O Operations

**23. What happens when the call stack becomes empty?**
- [ ] The program terminates
- [ ] The event loop checks for pending tasks
- [ ] The heap is garbage collected
- [ ] The program enters an idle state

**24. Which of the following is a microtask?**
- [ ] setTimeout
- [ ] setInterval
- [ ] Promise.then
- [ ] I/O Operations

**25. True or False: setTimeout(0) guarantees immediate execution.**
- [ ] True
- [ ] False

**26. What is the main difference between microtasks and macrotasks?**
- [ ] Microtasks run in the heap, macrotasks run in the stack
- [ ] Microtasks have higher priority and run before macrotasks
- [ ] Microtasks are synchronous, macrotasks are asynchronous
- [ ] There is no difference

**27. Which of the following can cause event loop starvation?**
- [ ] Using setTimeout
- [ ] Using Promise.then
- [ ] A synchronous infinite loop
- [ ] Using setImmediate

**28. What is the heap used for?**
- [ ] Tracking function execution
- [ ] Storing objects and functions in memory
- [ ] Managing asynchronous operations
- [ ] Handling I/O operations

#### Section 1.1.2: Short Answer (5 Questions)

**29.** Explain why `process.nextTick` is more dangerous than `setTimeout` in the context of malicious packages.
_________________________________________________________________
_________________________________________________________________

**30.** What is the relationship between the event loop and the call stack?
_________________________________________________________________
_________________________________________________________________

**31.** Why would a malicious package use `Promise.then` instead of `setTimeout`?
_________________________________________________________________
_________________________________________________________________

**32.** How can synchronous code block the event loop?
_________________________________________________________________
_________________________________________________________________

**33.** Describe the execution order of the following:
```javascript
console.log('A');
setTimeout(() => console.log('B'), 0);
Promise.resolve().then(() => console.log('C'));
process.nextTick(() => console.log('D'));
console.log('E');
```
Write the output order: __, __, __, __, __

### Module 1.2: npm Install Lifecycle

#### Section 1.2.1: Multiple Choice (8 Questions)

**34. Which npm script phase has the HIGHEST risk level?**
- [ ] preinstall
- [ ] install
- [ ] postinstall
- [ ] All of the above have equal risk

**35. When does the `postinstall` script execute?**
- [ ] Before installation
- [ ] During installation
- [ ] After installation
- [ ] During uninstallation

**36. Which script runs BEFORE any security checks?**
- [ ] install
- [ ] postinstall
- [ ] preinstall
- [ ] prepublish

**37. What is the most common attack vector in npm packages?**
- [ ] preinstall scripts
- [ ] install scripts
- [ ] postinstall scripts
- [ ] test scripts

**38. Which of the following is NOT a lifecycle script?**
- [ ] preinstall
- [ ] install
- [ ] postinstall
- [ ] autoupdate

**39. What permissions do npm scripts run with?**
- [ ] Restricted permissions
- [ ] The permissions of the user running npm install
- [ ] Sandboxed permissions
- [ ] No permissions

**40. Which script runs when a package is being removed?**
- [ ] preinstall
- [ ] postinstall
- [ ] preuninstall
- [ ] prepublish

**41. What is the primary security concern with lifecycle scripts?**
- [ ] They are slow
- [ ] They can execute arbitrary code with user permissions
- [ ] They require internet access
- [ ] They are difficult to write

#### Section 1.2.2: Matching (5 Questions)

**42. Match each script to its execution time:**

| Script | Execution Time |
|--------|----------------|
| a) preinstall | 1. During installation |
| b) install | 2. Before installation |
| c) postinstall | 3. After installation |
| d) preuninstall | 4. Before removal |
| e) prepublish | 5. Before publishing |

**Answers:** a-___ b-___ c-___ d-___ e-___

#### Section 1.2.3: Short Answer (4 Questions)

**43.** Why is `postinstall` considered the most dangerous script?
_________________________________________________________________
_________________________________________________________________

**44.** What would you look for in a `preinstall` script to determine if it's malicious?
_________________________________________________________________
_________________________________________________________________

**45.** How can you safely install a package without executing its scripts?
_________________________________________________________________
_________________________________________________________________

**46.** What information from package.json is most important for security analysis?
_________________________________________________________________
_________________________________________________________________

### Module 1.3: Building the Scanner

#### Section 1.3.1: Multiple Choice (8 Questions)

**47. What is the primary purpose of the security scanner?**
- [ ] To install packages
- [ ] To analyze packages for security risks
- [ ] To publish packages
- [ ] To delete packages

**48. Which component is NOT part of the scanner architecture?**
- [ ] Package.json parsing
- [ ] Dependency scanning
- [ ] Behavioral analysis
- [ ] Package publishing

**49. What is the first step in the scanner's analysis?**
- [ ] Scan JavaScript files
- [ ] Parse package.json
- [ ] Check for vulnerabilities
- [ ] Generate report

**50. How does the scanner detect malicious patterns?**
- [ ] By executing the code
- [ ] By pattern matching against known malicious patterns
- [ ] By asking the user
- [ ] By using machine learning

**51. What is the risk level determined by?**
- [ ] A random number
- [ ] The number of dependencies
- [ ] The severity and frequency of findings
- [ ] The package size

**52. Which command runs the scanner in CI mode?**
- [ ] node scanner.js
- [ ] node scanner.js --ci
- [ ] node scanner.js --report
- [ ] node scanner.js --scan

**53. What should be the action for CRITICAL risk packages in CI/CD?**
- [ ] Review
- [ ] Block
- [ ] Monitor
- [ ] Install

**54. What format can the scanner output reports in?**
- [ ] JSON only
- [ ] HTML only
- [ ] JSON, HTML, and Markdown
- [ ] XML only

#### Section 1.3.2: Short Answer (4 Questions)

**55.** How does the scanner's risk scoring system work?
_________________________________________________________________
_________________________________________________________________

**56.** What is the role of CI/CD integration in security scanning?
_________________________________________________________________
_________________________________________________________________

**57.** How would you customize the scanner to detect a new threat pattern?
_________________________________________________________________
_________________________________________________________________

**58.** What is the difference between a detection and a vulnerability?
_________________________________________________________________
_________________________________________________________________

### Module 1.4: Phase 1 Final Exam

#### Section 1.4.1: Multiple Choice (10 Questions)

**59. What is the correct order of JavaScript execution priorities?**
- [ ] Macrotasks → Microtasks → Call Stack
- [ ] Call Stack → Microtasks → Macrotasks
- [ ] Microtasks → Call Stack → Macrotasks
- [ ] Macrotasks → Call Stack → Microtasks

**60. Which npm lifecycle script has the HIGHEST risk?**
- [ ] preinstall
- [ ] install
- [ ] postinstall
- [ ] All have equal risk

**61. What is the purpose of the event loop?**
- [ ] To manage memory allocation
- [ ] To handle asynchronous operations
- [ ] To compile JavaScript code
- [ ] To manage dependencies

**62. Which of the following is a detection pattern for shell execution?**
- [ ] process.env
- [ ] fs.readFile
- [ ] child_process.exec
- [ ] eval

**63. What is a typosquatting attack?**
- [ ] Installing a package with a misspelled name
- [ ] Publishing a package with a similar name to a popular package
- [ ] Deleting a package from the registry
- [ ] Changing a package's version

**64. Which command prevents npm scripts from executing?**
- [ ] npm install --no-scripts
- [ ] npm install --ignore-scripts
- [ ] npm install --skip-scripts
- [ ] npm install --safe

**65. What is the purpose of the lock file?**
- [ ] To lock packages so they can't be updated
- [ ] To record exact versions of installed dependencies
- [ ] To prevent installation of packages
- [ ] To encrypt package contents

**66. What is a dependency confusion attack?**
- [ ] Installing packages in the wrong order
- [ ] Publishing a public version of an internal package name
- [ ] Confusing two packages with similar names
- [ ] Installing too many dependencies

**67. What is the scanner's risk score range?**
- [ ] 0-50
- [ ] 0-100
- [ ] 0-1000
- [ ] 0-10

**68. What is the primary benefit of behavioral analysis?**
- [ ] It is faster than CVE scanning
- [ ] It detects threats without known CVEs
- [ ] It uses less memory
- [ ] It is easier to implement

#### Section 1.4.2: Essay Questions (3 Questions)

**69.** Describe the complete npm install lifecycle and explain the security implications of each phase.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**70.** Explain how the JavaScript event loop can be exploited by malicious packages, providing specific attack examples.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**71.** Design a risk scoring system for a security scanner, explaining what factors you would include and how you would weight them.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## PHASE 2: MODERN DEPENDENCY RISK ANALYSIS - MODULE QUIZZES

### Module 2.1: Package Manifest Analysis

#### Section 2.1.1: Multiple Choice (8 Questions)

**72. What information is contained in package.json?**
- [ ] Only the package name
- [ ] Metadata, scripts, and dependencies
- [ ] Only the version number
- [ ] The entire source code

**73. What is the purpose of a lock file?**
- [ ] To prevent package updates
- [ ] To ensure deterministic installations
- [ ] To store the package source code
- [ ] To manage user permissions

**74. Which of the following indicates a dependency confusion attack?**
- [ ] A private package with scoped dependencies
- [ ] A private package with unscoped dependencies
- [ ] A public package with scoped dependencies
- [ ] A public package with no dependencies

**75. What does a lock file contain that package.json doesn't?**
- [ ] Package names
- [ ] Version constraints
- [ ] Exact versions and integrity hashes
- [ ] Script definitions

**76. What is a suspicious version number pattern for dependency confusion?**
- [ ] 1.0.0
- [ ] 2.1.3
- [ ] 999.0.0
- [ ] 0.1.0

**77. How can you mitigate dependency confusion risks?**
- [ ] Use unscoped package names
- [ ] Use scoped packages (@company/package)
- [ ] Use wildcard versions
- [ ] Avoid using lock files

**78. What is the difference between `dependencies` and `devDependencies`?**
- [ ] There is no difference
- [ ] dependencies are for production, devDependencies are for development
- [ ] dependencies are required, devDependencies are optional
- [ ] dependencies are installed globally

**79. What is the main risk of using overly permissive version ranges?**
- [ ] Slower installation
- [ ] Unexpected breaking changes
- [ ] Missing security updates
- [ ] License violations

#### Section 2.1.2: Short Answer (4 Questions)

**80.** How would you detect a dependency confusion attack in a project?
_________________________________________________________________
_________________________________________________________________

**81.** What is the relationship between package.json and package-lock.json?
_________________________________________________________________
_________________________________________________________________

**82.** Why is it important to review package.json before installing a package?
_________________________________________________________________
_________________________________________________________________

**83.** How would you verify the integrity of an installed package?
_________________________________________________________________
_________________________________________________________________

### Module 2.2: Capability Scanning

#### Section 2.2.1: Multiple Choice (8 Questions)

**84. What is a capability in the context of package security?**
- [ ] The package's advertised features
- [ ] A security-sensitive operation the package can perform
- [ ] The package's size on disk
- [ ] The package's version number

**85. Which capability has the HIGHEST risk level?**
- [ ] FILESYSTEM_ACCESS
- [ ] NETWORK_ACCESS
- [ ] SHELL_EXECUTION
- [ ] ENVIRONMENT_ACCESS

**86. How does AST-based analysis work?**
- [ ] By executing the code and observing behavior
- [ ] By analyzing the code structure without executing it
- [ ] By scanning the compiled binary
- [ ] By querying the package registry

**87. What does DYNAMIC_CODE detection look for?**
- [ ] HTTP requests
- [ ] eval, new Function, vm
- [ ] File system operations
- [ ] Environment variable access

**88. Which capability is most commonly associated with data exfiltration?**
- [ ] FILESYSTEM_ACCESS
- [ ] NETWORK_ACCESS
- [ ] SHELL_EXECUTION
- [ ] CRYPTOGRAPHY

**89. What is the purpose of risk scoring in capability analysis?**
- [ ] To rank packages by popularity
- [ ] To prioritize remediation efforts
- [ ] To determine package size
- [ ] To identify maintainers

**90. Which of the following is NOT a detectable capability?**
- [ ] Network communication
- [ ] Shell execution
- [ ] Code obfuscation
- [ ] Filesystem access

**91. What is the risk level of TELEMETRY capabilities?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

#### Section 2.2.2: Short Answer (4 Questions)

**92.** Explain the difference between capability scanning and vulnerability scanning.
_________________________________________________________________
_________________________________________________________________

**93.** Why is analyzing code using an AST safer than executing it?
_________________________________________________________________
_________________________________________________________________

**94.** How would you detect a package that attempts to read environment variables?
_________________________________________________________________
_________________________________________________________________

**95.** What makes SHELL_EXECUTION a critical risk capability?
_________________________________________________________________
_________________________________________________________________

### Module 2.3: Socket vs. Snyk Comparison

#### Section 2.3.1: Multiple Choice (8 Questions)

**96. Which tool specializes in behavioral analysis?**
- [ ] Snyk
- [ ] Socket
- [ ] Both
- [ ] Neither

**97. Which tool provides comprehensive CVE coverage?**
- [ ] Snyk
- [ ] Socket
- [ ] Both
- [ ] Neither

**98. Which tool is better at detecting zero-day threats?**
- [ ] Snyk
- [ ] Socket
- [ ] Both
- [ ] Neither

**99. What is the primary focus of Snyk?**
- [ ] Behavioral analysis
- [ ] Vulnerability detection and remediation
- [ ] Supply chain risk assessment
- [ ] Code obfuscation detection

**100. What is the primary focus of Socket?**
- [ ] CVE detection
- [ ] Behavioral analysis and supply chain security
- [ ] License compliance
- [ ] Code quality

**101. Which tool would you use for detecting typosquatting?**
- [ ] Snyk
- [ ] Socket
- [ ] Both
- [ ] Neither

**102. Which tool provides detailed remediation advice?**
- [ ] Snyk
- [ ] Socket
- [ ] Both
- [ ] Neither

**103. What is the advantage of using both tools together?**
- [ ] It's cheaper
- [ ] Provides comprehensive coverage
- [ ] Eliminates the need for manual review
- [ ] Speeds up the process

#### Section 2.3.2: Short Answer (4 Questions)

**104.** When would you choose Socket over Snyk?
_________________________________________________________________
_________________________________________________________________

**105.** When would you choose Snyk over Socket?
_________________________________________________________________
_________________________________________________________________

**106.** How do Socket and Snyk complement each other?
_________________________________________________________________
_________________________________________________________________

**107.** How would you integrate both tools into a single security pipeline?
_________________________________________________________________
_________________________________________________________________

### Module 2.4: Phase 2 Final Exam

#### Section 2.4.1: Multiple Choice (10 Questions)

**108. What is the first step in package security analysis?**
- [ ] Scan for vulnerabilities
- [ ] Parse package.json
- [ ] Analyze capabilities
- [ ] Generate report

**109. Which file contains the exact version of installed dependencies?**
- [ ] package.json
- [ ] package-lock.json
- [ ] .npmrc
- [ ] .gitignore

**110. What is the risk level of FILESYSTEM_ACCESS?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

**111. How does Socket detect typosquatting?**
- [ ] By checking download statistics
- [ ] By comparing package names using similarity algorithms
- [ ] By scanning package contents
- [ ] By checking maintainer history

**112. What is a dependency confusion attack?**
- [ ] Installing packages in the wrong order
- [ ] Publishing a public version of an internal package
- [ ] Confusing two similar packages
- [ ] Using too many dependencies

**113. Which tool provides comprehensive vulnerability coverage?**
- [ ] Socket
- [ ] Snyk
- [ ] Both
- [ ] Neither

**114. What is the purpose of AST analysis?**
- [ ] To execute code safely
- [ ] To analyze code without executing it
- [ ] To compile code faster
- [ ] To manage dependencies

**115. What is the risk level of SHELL_EXECUTION?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

**116. Which tool is better for detecting supply chain attacks?**
- [ ] Snyk
- [ ] Socket
- [ ] Both equally
- [ ] Neither

**117. What is the primary purpose of risk scoring?**
- [ ] To rank packages by size
- [ ] To prioritize security actions
- [ ] To determine package popularity
- [ ] To calculate installation time

#### Section 2.4.2: Essay Questions (3 Questions)

**118.** Compare and contrast Socket and Snyk, explaining when you would use each tool and what their respective strengths are.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**119.** Design a comprehensive package security analysis pipeline that includes both static analysis and behavioral detection.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**120.** Explain how you would detect and mitigate dependency confusion attacks in an enterprise environment.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## PHASE 3: ASYNCHRONOUS EXECUTION & SECURE ORCHESTRATION - MODULE QUIZZES

### Module 3.1: Concurrency Patterns

#### Section 3.1.1: Multiple Choice (8 Questions)

**121. What is the primary benefit of concurrent processing?**
- [ ] Reduced memory usage
- [ ] Faster processing of multiple items
- [ ] Simpler code
- [ ] Better security

**122. What is a worker pool?**
- [ ] A single worker processing all items
- [ ] Multiple workers processing items in parallel
- [ ] A queue for storing items
- [ ] A cache for results

**123. What is the purpose of a concurrency controller?**
- [ ] To control the number of simultaneous operations
- [ ] To control the speed of operations
- [ ] To control the memory usage
- [ ] To control the network bandwidth

**124. Why is timeout handling important?**
- [ ] To prevent operations from hanging indefinitely
- [ ] To speed up processing
- [ ] To reduce memory usage
- [ ] To improve code quality

**125. What is the AbortController used for?**
- [ ] To control the event loop
- [ ] To cancel ongoing operations
- [ ] To manage memory
- [ ] To handle errors

**126. What is the purpose of retry logic?**
- [ ] To handle transient failures
- [ ] To slow down processing
- [ ] To reduce memory usage
- [ ] To improve performance

**127. What is the best concurrency level for a given task?**
- [ ] Always use the maximum
- [ ] Always use the minimum
- [ ] It depends on the task and available resources
- [ ] It doesn't matter

**128. Which of the following is a concurrency pattern?**
- [ ] Sequential processing
- [ ] Parallel processing
- [ ] Pipeline processing
- [ ] All of the above

#### Section 3.1.2: Short Answer (4 Questions)

**129.** Explain the difference between sequential and parallel processing.
_________________________________________________________________
_________________________________________________________________

**130.** How would you implement retry logic with exponential backoff?
_________________________________________________________________
_________________________________________________________________

**131.** Why is it important to handle timeouts in security scanning?
_________________________________________________________________
_________________________________________________________________

**132.** What factors determine the optimal concurrency level?
_________________________________________________________________
_________________________________________________________________

### Module 3.2: Resource Management

#### Section 3.2.1: Multiple Choice (8 Questions)

**133. What is resource management in the context of security scanning?**
- [ ] Managing the number of packages
- [ ] Monitoring and controlling system resources
- [ ] Managing the security team
- [ ] Managing the budget

**134. Which resource is most critical to monitor?**
- [ ] Disk space
- [ ] Memory usage
- [ ] Network bandwidth
- [ ] Number of files

**135. What is the recommended maximum memory usage percentage?**
- [ ] 50%
- [ ] 60%
- [ ] 80%
- [ ] 95%

**136. What happens when memory pressure is high?**
- [ ] The system speeds up
- [ ] The system may become unstable
- [ ] The system uses less memory
- [ ] The system crashes immediately

**137. What is the purpose of the health check?**
- [ ] To verify the system is functioning properly
- [ ] To check the version number
- [ ] To update dependencies
- [ ] To log errors

**138. What is graceful degradation?**
- [ ] Reducing functionality when resources are limited
- [ ] Speeding up when resources are available
- [ ] Always using maximum resources
- [ ] Never reducing functionality

**139. What is the purpose of the Resource Manager?**
- [ ] To manage the security team
- [ ] To monitor and manage system resources
- [ ] To manage the package registry
- [ ] To manage the budget

**140. How can you prevent out-of-memory errors in the scanner?**
- [ ] By using more memory
- [ ] By reducing concurrency when memory is low
- [ ] By using a faster computer
- [ ] By using less code

#### Section 3.2.2: Short Answer (4 Questions)

**141.** What are the key system resources to monitor in a security scanner?
_________________________________________________________________
_________________________________________________________________

**142.** How would you implement memory-aware scheduling?
_________________________________________________________________
_________________________________________________________________

**143.** What is the relationship between concurrency and resource usage?
_________________________________________________________________
_________________________________________________________________

**144.** How would you handle a scenario where the system is running out of memory?
_________________________________________________________________
_________________________________________________________________

### Module 3.3: Priority Queuing

#### Section 3.3.1: Multiple Choice (8 Questions)

**145. What is the purpose of priority queuing?**
- [ ] To process items in any order
- [ ] To ensure critical items are processed first
- [ ] To speed up processing
- [ ] To reduce memory usage

**146. Which priority should security patches have?**
- [ ] LOW
- [ ] MEDIUM
- [ ] HIGH
- [ ] CRITICAL

**147. What is priority aging?**
- [ ] Increasing priority over time
- [ ] Decreasing priority over time
- [ ] Removing items after a time
- [ ] Adding items to a queue

**148. What is priority inversion?**
- [ ] High priority items being blocked by low priority items
- [ ] Low priority items being processed first
- [ ] Items being processed in random order
- [ ] All items having equal priority

**149. What is starvation in a priority queue?**
- [ ] Items being processed too quickly
- [ ] Items never being processed because of higher priority items
- [ ] Items being processed in the wrong order
- [ ] Items being duplicated

**150. How can you prevent starvation?**
- [ ] By using priority aging
- [ ] By disabling the queue
- [ ] By using a single priority level
- [ ] By processing items randomly

**151. Which priority level is appropriate for development dependencies?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] BACKGROUND

**152. What is the default priority level?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

#### Section 3.3.2: Short Answer (4 Questions)

**153.** Explain the different priority levels and when to use each.
_________________________________________________________________
_________________________________________________________________

**154.** What is priority inversion and how can it be prevented?
_________________________________________________________________
_________________________________________________________________

**155.** How would you implement priority aging?
_________________________________________________________________
_________________________________________________________________

**156.** Why is it important to process critical packages first?
_________________________________________________________________
_________________________________________________________________

### Module 3.4: Phase 3 Final Exam

#### Section 3.4.1: Multiple Choice (10 Questions)

**157. Which concurrency pattern is best for CPU-bound tasks?**
- [ ] Sequential
- [ ] Parallel with limited workers
- [ ] Pipeline
- [ ] Circular

**158. What is the main purpose of a concurrency controller?**
- [ ] To speed up processing
- [ ] To control the number of simultaneous operations
- [ ] To reduce memory usage
- [ ] To simplify code

**159. What is the primary benefit of streaming results?**
- [ ] Faster processing
- [ ] Real-time monitoring
- [ ] Lower memory usage
- [ ] Simpler code

**160. What is the purpose of the priority queue?**
- [ ] To process items in any order
- [ ] To ensure critical items are processed first
- [ ] To reduce memory usage
- [ ] To speed up processing

**161. What is the relationship between concurrency and memory usage?**
- [ ] Higher concurrency always means lower memory usage
- [ ] Higher concurrency always means higher memory usage
- [ ] Higher concurrency generally means higher memory usage
- [ ] There is no relationship

**162. How does the scanner handle failed items?**
- [ ] It ignores them
- [ ] It retries them with backoff
- [ ] It stops the entire process
- [ ] It deletes them

**163. What is the purpose of the Resource Manager?**
- [ ] To monitor system resources
- [ ] To manage packages
- [ ] To generate reports
- [ ] To send notifications

**164. How can you prevent event loop starvation in the scanner?**
- [ ] By using synchronous operations
- [ ] By yielding to the event loop
- [ ] By using more threads
- [ ] By using less code

**165. What is the advantage of using a worker pool?**
- [ ] It uses less memory
- [ ] It allows parallel processing
- [ ] It simplifies code
- [ ] It improves security

**166. What is the purpose of the Orchestrator?**
- [ ] To coordinate all components
- [ ] To generate reports
- [ ] To install packages
- [ ] To publish packages

#### Section 3.4.2: Essay Questions (3 Questions)

**167.** Design a concurrent security scanner architecture that can handle 10,000 packages efficiently while managing resources and handling failures.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**168.** Explain how priority queuing, resource management, and concurrency control work together in the orchestration layer.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**169.** How would you implement graceful degradation in a security scanner when system resources are low?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## PHASE 4: AI-AUGMENTED SECURITY - MODULE QUIZZES

### Module 4.1: LLM Integration

#### Section 4.1.1: Multiple Choice (8 Questions)

**170. What is the primary role of LLM in the security system?**
- [ ] To make security decisions
- [ ] To augment human security teams
- [ ] To replace security teams
- [ ] To eliminate the need for policies

**171. Which LLM providers are supported?**
- [ ] OpenAI only
- [ ] Anthropic only
- [ ] Both OpenAI and Anthropic
- [ ] Neither

**172. Why is structured output important?**
- [ ] It looks better
- [ ] It enables automated processing
- [ ] It uses less tokens
- [ ] It is faster

**173. What is the purpose of the schema validator?**
- [ ] To validate AI output
- [ ] To validate input data
- [ ] To validate package.json
- [ ] To validate lock files

**174. How should AI failures be handled?**
- [ ] Stop the entire system
- [ ] Use fallback analysis
- [ ] Ignore them
- [ ] Retry indefinitely

**175. What is the role of the system prompt?**
- [ ] To provide user input
- [ ] To define the AI's role and constraints
- [ ] To specify the output format
- [ ] To provide examples

**176. Why is fallback analysis important?**
- [ ] To save money
- [ ] To ensure the system works when AI fails
- [ ] To improve performance
- [ ] To reduce complexity

**177. What information is tracked in AI usage statistics?**
- [ ] Only the number of requests
- [ ] Number of requests, tokens, and cost
- [ ] Only the response time
- [ ] Only the error count

#### Section 4.1.2: Short Answer (4 Questions)

**178.** Why should AI never be the authoritative decision-maker in security?
_________________________________________________________________
_________________________________________________________________

**179.** What is the purpose of output validation?
_________________________________________________________________
_________________________________________________________________

**180.** How would you handle a malformed AI response?
_________________________________________________________________
_________________________________________________________________

**181.** What is the difference between the system prompt and the task prompt?
_________________________________________________________________
_________________________________________________________________

### Module 4.2: Prompt Engineering

#### Section 4.2.1: Multiple Choice (8 Questions)

**182. What is the purpose of the system prompt?**
- [ ] To provide examples
- [ ] To define the AI's role and constraints
- [ ] To specify the output format
- [ ] To provide the data to analyze

**183. What is few-shot learning?**
- [ ] Training the AI with many examples
- [ ] Providing examples in the prompt
- [ ] Using a smaller model
- [ ] Training with less data

**184. What is chain-of-thought prompting?**
- [ ] Asking for step-by-step reasoning
- [ ] Asking for a final answer only
- [ ] Providing multiple examples
- [ ] Using a specific format

**185. Why is output schema important?**
- [ ] It makes the output look better
- [ ] It ensures consistent structured output
- [ ] It reduces token usage
- [ ] It improves speed

**186. What is the effect of lower temperature on AI output?**
- [ ] More creative responses
- [ ] More deterministic responses
- [ ] Faster responses
- [ ] Slower responses

**187. What is a security prompt template?**
- [ ] A fixed prompt for all scenarios
- [ ] A structured prompt for security analysis
- [ ] A prompt that includes examples
- [ ] A prompt that uses chain-of-thought

**188. What should be included in the context prompt?**
- [ ] The AI's role
- [ ] The specific data to analyze
- [ ] The output format
- [ ] The examples

**189. What is the purpose of examples in prompts?**
- [ ] To fill space
- [ ] To demonstrate expected output format
- [ ] To train the AI
- [ ] To make the prompt longer

#### Section 4.2.2: Short Answer (4 Questions)

**190.** What are the key components of a well-designed security prompt?
_________________________________________________________________
_________________________________________________________________

**191.** How would you use few-shot learning for package security analysis?
_________________________________________________________________
_________________________________________________________________

**192.** What is the difference between chain-of-thought and standard prompting?
_________________________________________________________________
_________________________________________________________________

**193.** How would you adapt a prompt for different risk levels?
_________________________________________________________________
_________________________________________________________________

### Module 4.3: CI/CD Integration

#### Section 4.3.1: Multiple Choice (8 Questions)

**194. What is the primary goal of CI/CD integration?**
- [ ] To automate builds
- [ ] To automatically check security in the pipeline
- [ ] To deploy code faster
- [ ] To reduce costs

**195. What happens when a critical vulnerability is found in CI/CD?**
- [ ] The build continues
- [ ] The build is paused
- [ ] The build fails
- [ ] The build is restarted

**196. Which notification channel is best for urgent alerts?**
- [ ] Email only
- [ ] Slack/SMS
- [ ] Documentation
- [ ] Log file

**197. What is the purpose of the webhook server?**
- [ ] To serve web pages
- [ ] To receive events from external systems
- [ ] To host the security scanner
- [ ] To store data

**198. What is a GitHub check run?**
- [ ] A way to run code on GitHub
- [ ] A status check integrated into pull requests
- [ ] A way to deploy code
- [ ] A way to test code

**199. What should a CI/CD security report contain?**
- [ ] Only the number of vulnerabilities
- [ ] Summary, findings, recommendations
- [ ] Only the risk score
- [ ] Only the package list

**200. Why is it important to notify teams of security findings?**
- [ ] To fill their inboxes
- [ ] To ensure timely remediation
- [ ] To track them
- [ ] To document them

**201. What is the purpose of the status check?**
- [ ] To check the system status
- [ ] To provide a pass/fail indicator in PRs
- [ ] To check the network
- [ ] To check the database

#### Section 4.3.2: Short Answer (4 Questions)

**202.** How would you integrate the security scanner into a GitHub Actions workflow?
_________________________________________________________________
_________________________________________________________________

**203.** What is the difference between a check run and a status check?
_________________________________________________________________
_________________________________________________________________

**204.** How would you configure notifications for different severity levels?
_________________________________________________________________
_________________________________________________________________

**205.** What information should be included in a security alert notification?
_________________________________________________________________
_________________________________________________________________

### Module 4.4: Phase 4 Final Exam

#### Section 4.4.1: Multiple Choice (10 Questions)

**206. What is the primary role of AI in the security system?**
- [ ] To make all security decisions
- [ ] To augment human judgment
- [ ] To replace security teams
- [ ] To eliminate policies

**207. Which of the following is a valid risk level?**
- [ ] EXTREME
- [ ] CRITICAL
- [ ] IMPORTANT
- [ ] URGENT

**208. What happens when AI output fails validation?**
- [ ] The system crashes
- [ ] Fallback analysis is used
- [ ] The output is ignored
- [ ] The system retries

**209. What is the purpose of the policy engine?**
- [ ] To generate AI recommendations
- [ ] To enforce deterministic security rules
- [ ] To validate AI output
- [ ] To send notifications

**210. Which component validates AI output?**
- [ ] Policy Engine
- [ ] Schema Validator
- [ ] AI Orchestrator
- [ ] Notification Service

**211. What is the role of the AI Orchestrator?**
- [ ] To coordinate all AI-related components
- [ ] To generate AI recommendations
- [ ] To validate AI output
- [ ] To send notifications

**212. When should a human override a policy decision?**
- [ ] Never
- [ ] Only with justification
- [ ] Always
- [ ] Only when the AI fails

**213. What is the purpose of logging AI interactions?**
- [ ] To fill storage
- [ ] To enable audit and review
- [ ] To improve performance
- [ ] To reduce errors

**214. How does the system handle AI API failures?**
- [ ] It crashes
- [ ] It uses fallback analysis
- [ ] It retries forever
- [ ] It ignores the failure

**215. What is the purpose of the unified security report?**
- [ ] To document the scan
- [ ] To provide actionable insights
- [ ] To track metrics
- [ ] All of the above

#### Section 4.4.2: Essay Questions (3 Questions)

**216.** Design a complete AI-augmented security pipeline, explaining how each component (LLM service, schema validator, policy engine, CI/CD integration) works together.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**217.** Explain the principle "AI recommends, policies decide, humans override" and provide examples of how this works in the system.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**218.** How would you implement a fallback strategy for AI failures in a production environment?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## PRIMERS: COMPREHENSIVE QUIZZES

### Primer 1: npm Package Structure and Installation

#### Section P1: Multiple Choice (10 Questions)

**219. What is the main entry point of an npm package?**
- [ ] package.json
- [ ] index.js
- [ ] README.md
- [ ] LICENSE

**220. Which file defines the package's metadata?**
- [ ] package-lock.json
- [ ] package.json
- [ ] .npmrc
- [ ] .gitignore

**221. What is the purpose of the `main` field in package.json?**
- [ ] To specify the main author
- [ ] To specify the entry point file
- [ ] To specify the version
- [ ] To specify the license

**222. Which npm command installs packages without executing scripts?**
- [ ] npm install
- [ ] npm install --ignore-scripts
- [ ] npm install --no-scripts
- [ ] npm install --skip-scripts

**223. What is the purpose of the `files` field?**
- [ ] To specify which files to include when publishing
- [ ] To specify which files to ignore
- [ ] To specify which files to compress
- [ ] To specify which files to encrypt

**224. Which lifecycle script runs after installation?**
- [ ] preinstall
- [ ] install
- [ ] postinstall
- [ ] prepublish

**225. What is the purpose of the `engines` field?**
- [ ] To specify the required Node.js version
- [ ] To specify the required npm version
- [ ] To specify the engine type
- [ ] To specify the runtime

**226. What is the purpose of the `private` field?**
- [ ] To make the package public
- [ ] To prevent accidental publishing
- [ ] To encrypt the package
- [ ] To restrict access

**227. What is the purpose of the `exports` field?**
- [ ] To export functions
- [ ] To define export mappings
- [ ] To export variables
- [ ] To export classes

**228. What is the purpose of the `peerDependencies` field?**
- [ ] Production dependencies
- [ ] Development dependencies
- [ ] Required peer dependencies
- [ ] Optional dependencies

#### Section P1: Short Answer (5 Questions)

**229.** Explain the difference between `dependencies` and `devDependencies`.
_________________________________________________________________
_________________________________________________________________

**230.** What is the purpose of the lock file and why is it important for security?
_________________________________________________________________
_________________________________________________________________

**231.** How would you review a package before installing it?
_________________________________________________________________
_________________________________________________________________

**232.** Why is it important to check lifecycle scripts before installing a package?
_________________________________________________________________
_________________________________________________________________

**233.** What are the security implications of the `prepare` script?
_________________________________________________________________
_________________________________________________________________

### Primer 2: Semantic Versioning and Dependency Resolution

#### Section P2: Multiple Choice (10 Questions)

**234. What does SemVer stand for?**
- [ ] Semantic Versioning
- [ ] Security Versioning
- [ ] Software Versioning
- [ ] System Versioning

**235. What does the MAJOR version number indicate?**
- [ ] Bug fixes
- [ ] Breaking changes
- [ ] New features
- [ ] Security patches

**236. What does the MINOR version number indicate?**
- [ ] Bug fixes
- [ ] Breaking changes
- [ ] New features (backward compatible)
- [ ] Security patches

**237. What does the PATCH version number indicate?**
- [ ] Bug fixes
- [ ] Breaking changes
- [ ] New features
- [ ] Major updates

**238. What does the caret (^) version range mean?**
- [ ] Exact version
- [ ] Compatible with all versions
- [ ] Up to next major version
- [ ] Up to next minor version

**239. What does the tilde (~) version range mean?**
- [ ] Exact version
- [ ] Compatible with all versions
- [ ] Up to next major version
- [ ] Up to next minor version

**240. What is the purpose of the lock file?**
- [ ] To lock the version in package.json
- [ ] To record exact versions installed
- [ ] To lock the registry
- [ ] To lock the dependencies

**241. Which of the following is a valid SemVer version?**
- [ ] 1.2
- [ ] 1.2.3
- [ ] 1.2.3.4
- [ ] 1

**242. What is dependency resolution?**
- [ ] The process of installing dependencies
- [ ] The process of determining which versions to install
- [ ] The process of updating dependencies
- [ ] The process of removing dependencies

**243. What is deduplication?**
- [ ] Removing duplicate packages
- [ ] Installing duplicate packages
- [ ] Updating packages
- [ ] Removing packages

#### Section P2: Short Answer (5 Questions)

**244.** Explain the difference between `^1.2.3` and `~1.2.3`.
_________________________________________________________________
_________________________________________________________________

**245.** What is the difference between `dependencies` and `peerDependencies`?
_________________________________________________________________
_________________________________________________________________

**246.** How does npm resolve conflicting version requirements?
_________________________________________________________________
_________________________________________________________________

**247.** Why is it important to use exact versions in production?
_________________________________________________________________
_________________________________________________________________

**248.** What is the relationship between package.json and package-lock.json?
_________________________________________________________________
_________________________________________________________________

### Primer 3: Package Registry Security

#### Section P3: Multiple Choice (10 Questions)

**249. What is the primary public registry for npm packages?**
- [ ] GitHub
- [ ] npmjs.com
- [ ] GitLab
- [ ] Bitbucket

**250. What is the purpose of the integrity hash?**
- [ ] To verify package content hasn't been tampered with
- [ ] To verify the maintainer's identity
- [ ] To verify the package name
- [ ] To verify the version

**251. What is authentication token used for?**
- [ ] To identify the user
- [ ] To authorize API requests
- [ ] To encrypt data
- [ ] To authenticate the registry

**252. What is 2FA?**
- [ ] Two-Factor Authentication
- [ ] Two-File Authentication
- [ ] Two-Form Authentication
- [ ] Two-Function Authentication

**253. What is a typosquatting attack?**
- [ ] Publishing a package with a similar name to a popular package
- [ ] Publishing a package with a misspelled name
- [ ] Publishing a package with the same name as a popular package
- [ ] Publishing a package with a different name

**254. What is dependency confusion?**
- [ ] Publishing a package with the same name as an internal package
- [ ] Publishing a package with a similar name
- [ ] Publishing a package with a different name
- [ ] Publishing a package with a higher version

**255. How can you prevent dependency confusion attacks?**
- [ ] Using unscoped packages
- [ ] Using scoped packages
- [ ] Using public packages
- [ ] Using private packages

**256. What is the purpose of package signing?**
- [ ] To verify the package has been reviewed
- [ ] To verify the package's authenticity
- [ ] To verify the package's size
- [ ] To verify the package's version

**257. What is provenance tracking?**
- [ ] Tracking the package's origin
- [ ] Tracking the package's size
- [ ] Tracking the package's version
- [ ] Tracking the package's dependencies

**258. What is a private registry?**
- [ ] A registry only accessible to authenticated users
- [ ] A registry with private packages
- [ ] A registry with hidden packages
- [ ] A registry with limited packages

#### Section P3: Short Answer (5 Questions)

**259.** What are the security benefits of using a private registry?
_________________________________________________________________
_________________________________________________________________

**260.** How does the registry verify package integrity?
_________________________________________________________________
_________________________________________________________________

**261.** What is the difference between authentication and authorization?
_________________________________________________________________
_________________________________________________________________

**262.** How would you detect a typosquatting package?
_________________________________________________________________
_________________________________________________________________

**263.** What are the risks of using public registries for internal packages?
_________________________________________________________________
_________________________________________________________________

### Primer 4: JavaScript Security Fundamentals

#### Section P4: Multiple Choice (10 Questions)

**264. What is prototype pollution?**
- [ ] Modifying the Object.prototype
- [ ] Modifying the function prototype
- [ ] Modifying the array prototype
- [ ] Modifying the string prototype

**265. How can you prevent prototype pollution?**
- [ ] Using Object.create(null)
- [ ] Using Object.create(prototype)
- [ ] Using new Object()
- [ ] Using Object.assign()

**266. What is XSS?**
- [ ] Cross-Site Scripting
- [ ] Cross-Site Security
- [ ] Cross-Site Standard
- [ ] Cross-Site System

**267. How can you prevent XSS attacks?**
- [ ] Escaping user input
- [ ] Encrypting user input
- [ ] Compressing user input
- [ ] Deleting user input

**268. What is command injection?**
- [ ] Injecting commands into SQL
- [ ] Injecting commands into the shell
- [ ] Injecting commands into JavaScript
- [ ] Injecting commands into HTML

**269. How can you prevent command injection?**
- [ ] Using execFile with arguments
- [ ] Using exec with user input
- [ ] Using eval with user input
- [ ] Using JSON.parse with user input

**270. What is path traversal?**
- [ ] Accessing files outside the intended directory
- [ ] Traversing the file system
- [ ] Traversing the network
- [ ] Traversing the path

**271. How can you prevent path traversal?**
- [ ] Normalizing and validating paths
- [ ] Using absolute paths
- [ ] Using relative paths
- [ ] Using encoded paths

**272. What is insecure deserialization?**
- [ ] Deserializing untrusted data
- [ ] Serializing secure data
- [ ] Deserializing secure data
- [ ] Serializing untrusted data

**273. How can you prevent insecure deserialization?**
- [ ] Using JSON.parse safely
- [ ] Using eval
- [ ] Using new Function
- [ ] Using vm.runInNewContext

#### Section P4: Short Answer (5 Questions)

**274.** Explain prototype pollution and how it can be exploited.
_________________________________________________________________
_________________________________________________________________

**275.** What are the three types of XSS attacks?
_________________________________________________________________
_________________________________________________________________

**276.** Why is `eval` dangerous in JavaScript?
_________________________________________________________________
_________________________________________________________________

**277.** How would you secure file path operations?
_________________________________________________________________
_________________________________________________________________

**278.** What is the difference between `exec` and `execFile`?
_________________________________________________________________
_________________________________________________________________

### Primer 5: Supply Chain Attack Patterns

#### Section P5: Multiple Choice (10 Questions)

**279. What is a supply chain attack?**
- [ ] Attacking the software supply chain
- [ ] Attacking the hardware supply chain
- [ ] Attacking the network supply chain
- [ ] Attacking the power supply chain

**280. What is typosquatting?**
- [ ] Publishing a package with a similar name to a popular package
- [ ] Publishing a package with a misspelled name
- [ ] Publishing a package with the same name as a popular package
- [ ] Publishing a package with a different name

**281. What is dependency confusion?**
- [ ] Publishing a package with the same name as an internal package
- [ ] Publishing a package with a similar name
- [ ] Publishing a package with a different name
- [ ] Publishing a package with a higher version

**282. What is a malicious script?**
- [ ] A script that performs malicious actions
- [ ] A script that performs security checks
- [ ] A script that performs tests
- [ ] A script that performs builds

**283. What is version hijacking?**
- [ ] Publishing a malicious version of a package
- [ ] Publishing a new version of a package
- [ ] Publishing a deprecated version of a package
- [ ] Publishing a secure version of a package

**284. What is social engineering?**
- [ ] Manipulating people to compromise security
- [ ] Manipulating systems to compromise security
- [ ] Manipulating networks to compromise security
- [ ] Manipulating data to compromise security

**285. What is maintainer compromise?**
- [ ] Compromising the maintainer's account
- [ ] Compromising the maintainer's computer
- [ ] Compromising the maintainer's network
- [ ] Compromising the maintainer's data

**286. What is protestware?**
- [ ] Packages with political messages
- [ ] Packages with security messages
- [ ] Packages with technical messages
- [ ] Packages with legal messages

**287. What is data exfiltration?**
- [ ] Stealing data
- [ ] Deleting data
- [ ] Encrypting data
- [ ] Backing up data

**288. What is backdoor installation?**
- [ ] Installing a backdoor for remote access
- [ ] Installing a security patch
- [ ] Installing a new feature
- [ ] Installing a bug fix

#### Section P5: Short Answer (5 Questions)

**289.** What are the most common supply chain attack patterns?
_________________________________________________________________
_________________________________________________________________

**290.** How would you detect typosquatting attacks?
_________________________________________________________________
_________________________________________________________________

**291.** What is the difference between typosquatting and dependency confusion?
_________________________________________________________________
_________________________________________________________________

**292.** How can you detect malicious install scripts?
_________________________________________________________________
_________________________________________________________________

**293.** What are the signs of a compromised maintainer account?
_________________________________________________________________
_________________________________________________________________

---

## FINAL COMPREHENSIVE EXAM

### Part A: Multiple Choice (50 Questions)

**294. What percentage of applications are assembled from open-source dependencies?**
- [ ] 50%
- [ ] 70%
- [ ] 90%
- [ ] 99%

**295. What is the primary limitation of traditional SCA tools?**
- [ ] They are too expensive
- [ ] They only check known vulnerabilities
- [ ] They don't work with JavaScript
- [ ] They require manual operation

**296. What is the call stack?**
- [ ] A region of memory for storing objects
- [ ] A LIFO structure that tracks function execution
- [ ] A queue for asynchronous operations
- [ ] A cache for frequently used functions

**297. Which of the following has the HIGHEST priority in the event loop?**
- [ ] setTimeout
- [ ] Promise.then
- [ ] process.nextTick
- [ ] I/O Operations

**298. Which npm script phase has the HIGHEST risk level?**
- [ ] preinstall
- [ ] install
- [ ] postinstall
- [ ] All of the above have equal risk

**299. What is the primary focus of Socket?**
- [ ] CVE detection
- [ ] Behavioral analysis and supply chain security
- [ ] License compliance
- [ ] Code quality

**300. What is the primary focus of Snyk?**
- [ ] Behavioral analysis
- [ ] Vulnerability detection and remediation
- [ ] Supply chain risk assessment
- [ ] Code obfuscation detection

**301. What is the purpose of the lock file?**
- [ ] To lock packages so they can't be updated
- [ ] To record exact versions of installed dependencies
- [ ] To prevent installation of packages
- [ ] To encrypt package contents

**302. What is a dependency confusion attack?**
- [ ] Installing packages in the wrong order
- [ ] Publishing a public version of an internal package name
- [ ] Confusing two packages with similar names
- [ ] Installing too many dependencies

**303. Which capability has the HIGHEST risk level?**
- [ ] FILESYSTEM_ACCESS
- [ ] NETWORK_ACCESS
- [ ] SHELL_EXECUTION
- [ ] ENVIRONMENT_ACCESS

**304. How does AST-based analysis work?**
- [ ] By executing the code and observing behavior
- [ ] By analyzing the code structure without executing it
- [ ] By scanning the compiled binary
- [ ] By querying the package registry

**305. What is the primary benefit of concurrent processing?**
- [ ] Reduced memory usage
- [ ] Faster processing of multiple items
- [ ] Simpler code
- [ ] Better security

**306. What is the purpose of the concurrency controller?**
- [ ] To control the number of simultaneous operations
- [ ] To control the speed of operations
- [ ] To control the memory usage
- [ ] To control the network bandwidth

**307. What is the purpose of priority queuing?**
- [ ] To process items in any order
- [ ] To ensure critical items are processed first
- [ ] To speed up processing
- [ ] To reduce memory usage

**308. What is the primary role of LLM in the security system?**
- [ ] To make security decisions
- [ ] To augment human security teams
- [ ] To replace security teams
- [ ] To eliminate the need for policies

**309. Why is structured output important?**
- [ ] It looks better
- [ ] It enables automated processing
- [ ] It uses less tokens
- [ ] It is faster

**310. What is the purpose of the schema validator?**
- [ ] To validate AI output
- [ ] To validate input data
- [ ] To validate package.json
- [ ] To validate lock files

**311. What happens when a critical vulnerability is found in CI/CD?**
- [ ] The build continues
- [ ] The build is paused
- [ ] The build fails
- [ ] The build is restarted

**312. What is the purpose of the webhook server?**
- [ ] To serve web pages
- [ ] To receive events from external systems
- [ ] To host the security scanner
- [ ] To store data

**313. What is typosquatting?**
- [ ] Publishing a package with a similar name to a popular package
- [ ] Publishing a package with a misspelled name
- [ ] Publishing a package with the same name as a popular package
- [ ] Publishing a package with a different name

**314. How can you prevent dependency confusion?**
- [ ] Using unscoped packages
- [ ] Using scoped packages
- [ ] Using public packages
- [ ] Using private packages

**315. What is prototype pollution?**
- [ ] Modifying the Object.prototype
- [ ] Modifying the function prototype
- [ ] Modifying the array prototype
- [ ] Modifying the string prototype

**316. How can you prevent XSS attacks?**
- [ ] Escaping user input
- [ ] Encrypting user input
- [ ] Compressing user input
- [ ] Deleting user input

**317. What is command injection?**
- [ ] Injecting commands into SQL
- [ ] Injecting commands into the shell
- [ ] Injecting commands into JavaScript
- [ ] Injecting commands into HTML

**318. How can you prevent command injection?**
- [ ] Using execFile with arguments
- [ ] Using exec with user input
- [ ] Using eval with user input
- [ ] Using JSON.parse with user input

**319. What is path traversal?**
- [ ] Accessing files outside the intended directory
- [ ] Traversing the file system
- [ ] Traversing the network
- [ ] Traversing the path

**320. What is maintainer compromise?**
- [ ] Compromising the maintainer's account
- [ ] Compromising the maintainer's computer
- [ ] Compromising the maintainer's network
- [ ] Compromising the maintainer's data

**321. What is the purpose of the `main` field in package.json?**
- [ ] To specify the main author
- [ ] To specify the entry point file
- [ ] To specify the version
- [ ] To specify the license

**322. What is the purpose of the `exports` field?**
- [ ] To export functions
- [ ] To define export mappings
- [ ] To export variables
- [ ] To export classes

**323. What is the purpose of the `peerDependencies` field?**
- [ ] Production dependencies
- [ ] Development dependencies
- [ ] Required peer dependencies
- [ ] Optional dependencies

**324. What does the caret (^) version range mean?**
- [ ] Exact version
- [ ] Compatible with all versions
- [ ] Up to next major version
- [ ] Up to next minor version

**325. What is the purpose of the integrity hash?**
- [ ] To verify package content hasn't been tampered with
- [ ] To verify the maintainer's identity
- [ ] To verify the package name
- [ ] To verify the version

**326. What is 2FA?**
- [ ] Two-Factor Authentication
- [ ] Two-File Authentication
- [ ] Two-Form Authentication
- [ ] Two-Function Authentication

**327. What is the purpose of package signing?**
- [ ] To verify the package has been reviewed
- [ ] To verify the package's authenticity
- [ ] To verify the package's size
- [ ] To verify the package's version

**328. What is a private registry?**
- [ ] A registry only accessible to authenticated users
- [ ] A registry with private packages
- [ ] A registry with hidden packages
- [ ] A registry with limited packages

**329. What is the purpose of the system prompt?**
- [ ] To provide user input
- [ ] To define the AI's role and constraints
- [ ] To specify the output format
- [ ] To provide examples

**330. What is few-shot learning?**
- [ ] Training the AI with many examples
- [ ] Providing examples in the prompt
- [ ] Using a smaller model
- [ ] Training with less data

**331. What is chain-of-thought prompting?**
- [ ] Asking for step-by-step reasoning
- [ ] Asking for a final answer only
- [ ] Providing multiple examples
- [ ] Using a specific format

**332. Why is fallback analysis important?**
- [ ] To save money
- [ ] To ensure the system works when AI fails
- [ ] To improve performance
- [ ] To reduce complexity

**333. What is the role of the policy engine?**
- [ ] To generate AI recommendations
- [ ] To enforce deterministic security rules
- [ ] To validate AI output
- [ ] To send notifications

**334. Which component validates AI output?**
- [ ] Policy Engine
- [ ] Schema Validator
- [ ] AI Orchestrator
- [ ] Notification Service

**335. What is the role of the AI Orchestrator?**
- [ ] To coordinate all AI-related components
- [ ] To generate AI recommendations
- [ ] To validate AI output
- [ ] To send notifications

**336. When should a human override a policy decision?**
- [ ] Never
- [ ] Only with justification
- [ ] Always
- [ ] Only when the AI fails

**337. What is the purpose of logging AI interactions?**
- [ ] To fill storage
- [ ] To enable audit and review
- [ ] To improve performance
- [ ] To reduce errors

**338. What is the purpose of the unified security report?**
- [ ] To document the scan
- [ ] To provide actionable insights
- [ ] To track metrics
- [ ] All of the above

**339. Which file contains the exact version of installed dependencies?**
- [ ] package.json
- [ ] package-lock.json
- [ ] .npmrc
- [ ] .gitignore

**340. What is the risk level of FILESYSTEM_ACCESS?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

**341. What is the risk level of SHELL_EXECUTION?**
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

**342. Which tool is better at detecting zero-day threats?**
- [ ] Snyk
- [ ] Socket
- [ ] Both equally
- [ ] Neither

**343. What is the purpose of the Resource Manager?**
- [ ] To manage the security team
- [ ] To monitor and manage system resources
- [ ] To manage the package registry
- [ ] To manage the budget

### Part B: Short Answer (20 Questions)

**344.** Explain the complete npm install lifecycle and the security implications of each phase.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**345.** How does the JavaScript event loop work and how can it be exploited by malicious packages?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**346.** Compare and contrast Socket and Snyk, explaining their strengths and weaknesses.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**347.** What are the different types of supply chain attacks and how can they be detected?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**348.** Explain the architecture of a concurrent security scanner, including how it handles resource management and priority queuing.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**349.** How does AST-based capability scanning work and why is it effective?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**350.** What is the role of AI in the security system and why should it never be the authoritative decision-maker?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**351.** How does the policy engine work and what is its relationship with AI recommendations?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**352.** Explain the components and flow of the CI/CD integration.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**353.** What are the key components of a well-designed security prompt for LLMs?
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

### Part C: Essay Questions (3 Questions)

**354.** Design a complete security pipeline that includes package analysis, capability scanning, AI augmentation, and CI/CD integration. Explain how each component works together and what security controls are in place.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**355.** Analyze the evolution of SCA from CVE-based scanning to modern behavioral analysis, explaining why each evolution was necessary and what new threats each addresses.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**356.** Write a detailed security policy for an enterprise that includes dependency approval, vulnerability management, and AI usage guidelines.
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## ANSWER KEYS

### Part 0: Introduction - Answer Key

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | C | 11 | False |
| 2 | B | 12 | False |
| 3 | D | 13 | True |
| 4 | B | 14 | False |
| 5 | B | 15 | True |
| 6 | B | 16 | 90 |
| 7 | A | 17 | behavior |
| 8 | C | 18 | Socket, Snyk |
| 9 | D | 19 | guardrails |
| 10 | B | 20 | deterministic |

### Phase 1 Answer Key

#### Module 1.1

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 21 | B | 26 | B |
| 22 | C | 27 | C |
| 23 | B | 28 | B |
| 24 | C | 33 | D, A, E, C, B |
| 25 | False | | |

**29.** `process.nextTick` is more dangerous because it has the highest priority in the event loop, executing immediately after the current call stack clears, before any other microtasks or macrotasks. Malicious packages can use it to execute code with no delay, making detection harder.

**30.** The event loop continuously checks if the call stack is empty. When the call stack is empty, the event loop processes tasks from the microtask queue, then the macrotask queue. The call stack handles synchronous execution while the event loop handles asynchronous operations.

**31.** `Promise.then` schedules a microtask which has higher priority than macrotasks like `setTimeout`. This allows the malicious code to execute sooner and potentially hide its execution among legitimate operations.

**32.** Synchronous code blocks the event loop because the call stack must be empty before the event loop can process any tasks. A long-running synchronous operation prevents any asynchronous operations from executing.

#### Module 1.2

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 34 | B | 39 | B |
| 35 | C | 40 | C |
| 36 | C | 41 | B |
| 37 | C | 42a | 2 |
| 38 | D | 42b | 1 |

| Q# | Answer |
|----|--------|
| 42c | 3 |
| 42d | 4 |
| 42e | 5 |

**43.** `postinstall` is considered most dangerous because it runs after the package is installed, when the developer may have moved on and is less likely to monitor. It has full permissions and can perform malicious actions without immediate detection.

**44.** In a `preinstall` script, look for:
- Shell command execution (exec, spawn)
- Network operations (http, https, fetch)
- File system operations (fs, readFile, writeFile)
- Environment variable access (process.env)
- Dynamic code execution (eval, Function)

**45.** Use `npm install --ignore-scripts` to install packages without executing any lifecycle scripts.

**46.** For security analysis, the most important information includes:
- Scripts (especially lifecycle scripts)
- Dependencies (names and versions)
- Private flag (indicates internal packages)
- Author and repository information

#### Module 1.3

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 47 | B | 52 | B |
| 48 | D | 53 | B |
| 49 | B | 54 | C |
| 50 | B | | |
| 51 | C | | |

**55.** The risk scoring system assigns points based on severity (CRITICAL=25, HIGH=15, MEDIUM=8, LOW=3) and multiplies by frequency. Total score determines risk level: 0-9=LOW, 10-29=MEDIUM, 30-49=HIGH, 50+=CRITICAL.

**56.** CI/CD integration automates security checks in the development pipeline, blocking vulnerable packages before they reach production. It ensures consistent security enforcement and provides immediate feedback to developers.

**57.** To customize the scanner, add new detection rules to the `detectionRules` array with patterns to match and severity levels. For more complex patterns, extend the `analyzeScripts` or `analyzeFile` methods.

**58.** A detection is a suspicious pattern identified by the scanner (e.g., shell command usage). A vulnerability is a confirmed security issue with a known exploit or CVE. Detections may or may not be actual vulnerabilities.

#### Module 1.4

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 59 | B | 64 | B |
| 60 | B | 65 | B |
| 61 | B | 66 | B |
| 62 | C | 67 | B |
| 63 | B | 68 | B |

**69.** The npm install lifecycle consists of:
- **preinstall**: Runs before installation, highest risk of pre-execution
- **install**: Runs during installation, full permissions
- **postinstall**: Runs after installation, most common attack vector
- Each phase can execute arbitrary code with user permissions
- Attackers exploit these phases for data exfiltration, backdoor installation, and persistence

**70.** The event loop can be exploited through:
- `process.nextTick`: Highest priority, executes immediately
- `Promise.then`: Microtask priority, hides malicious code
- `setTimeout`: Delayed execution, evades detection
- Event loop starvation: Denial of service via synchronous loops

**71.** A risk scoring system should include:
- Severity of findings (weighted 1-25)
- Frequency of occurrences
- Context (production vs development)
- Exploit availability
- Fix availability
- Business impact
- Score range: 0-100
- Levels: LOW (0-19), MEDIUM (20-49), HIGH (50-79), CRITICAL (80-100)

### Phase 2 Answer Key

#### Module 2.1

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 72 | B | 76 | C |
| 73 | B | 77 | B |
| 74 | B | 78 | B |
| 75 | C | 79 | B |

**80.** To detect dependency confusion:
- Check if package is private
- Check for unscoped dependencies
- Verify version numbers (especially suspicious versions like 999.0.0)
- Verify registry configuration
- Compare public and private registries

**81.** package.json defines version ranges while package-lock.json records exact versions installed. The lock file ensures deterministic installations and provides integrity verification.

**82.** Reviewing package.json before installation helps identify:
- Suspicious lifecycle scripts
- Unusual dependencies
- Suspicious version patterns
- Private/public status
- Potential supply chain risks

**83.** To verify integrity:
- Compare package-lock.json integrity hashes with installed files
- Use `npm ci` for deterministic installs
- Verify package signature (if available)
- Use `npm audit` to check for known issues

#### Module 2.2

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 84 | B | 88 | B |
| 85 | C | 89 | B |
| 86 | B | 90 | C |
| 87 | B | 91 | C |

**92.** Capability scanning detects what a package CAN do (filesystem access, network, shell) while vulnerability scanning checks what KNOWN ISSUES it has (CVEs). Capability scanning catches unknown threats while vulnerability scanning catches known ones.

**93.** AST analysis is safer because it parses the code structure without executing it. This prevents potential side effects of running malicious code while still detecting dangerous patterns.

**94.** To detect environment variable access, look for:
- `process.env` usage
- `Object.keys(process.env)`
- `JSON.stringify(process.env)`
- Individual environment variable access (e.g., `process.env.NODE_ENV`)

**95.** SHELL_EXECUTION is critical because it allows arbitrary system command execution, giving the package complete access to the system with the user's permissions.

#### Module 2.3

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 96 | B | 100 | B |
| 97 | A | 101 | B |
| 98 | B | 102 | A |
| 99 | B | 103 | B |

**104.** Use Socket when:
- Evaluating new packages
- Concerned about supply chain attacks
- Need behavioral analysis
- Detecting zero-day threats
- Building dependency approval process

**105.** Use Snyk when:
- Managing existing dependencies
- Need to fix known vulnerabilities
- Require CVE-based compliance
- Need remediation advice
- Integrating with existing tools

**106.** Socket provides behavioral detection (unknown threats) while Snyk provides vulnerability detection (known threats). Together they provide comprehensive coverage.

**107.** To integrate both tools:
1. Run both analyses in parallel
2. Merge results into unified format
3. Compare findings for conflicts
4. Generate combined recommendations
5. Use unified risk scoring

#### Module 2.4

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 108 | B | 113 | B |
| 109 | B | 114 | B |
| 110 | B | 115 | A |
| 111 | B | 116 | B |
| 112 | B | 117 | B |

**118.** Socket focuses on behavioral analysis and supply chain security, detecting zero-day threats. Snyk focuses on vulnerability detection and remediation, providing comprehensive CVE coverage. Use Socket for new package evaluation and supply chain risk, use Snyk for existing dependency management and remediation.

**119.** A comprehensive pipeline should include:
1. Package.json parsing
2. Lock file analysis
3. Capability scanning (AST-based)
4. Vulnerability checking (CVE databases)
5. Risk scoring
6. Policy enforcement
7. Report generation
8. CI/CD integration

**120.** To detect and mitigate dependency confusion:
- Use scoped packages (@company/package)
- Configure private registry in .npmrc
- Pin exact versions
- Implement package name reservation
- Monitor for suspicious version numbers
- Regular registry audits

### Phase 3 Answer Key

#### Module 3.1

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 121 | B | 125 | B |
| 122 | B | 126 | A |
| 123 | A | 127 | C |
| 124 | A | 128 | D |

**129.** Sequential processing handles one item at a time; parallel processing handles multiple items simultaneously using multiple workers. Parallel processing is faster but requires resource management.

**130.** Exponential backoff retry:
```
async function retryWithBackoff(fn, maxRetries = 3) {
    let attempt = 0;
    while (attempt < maxRetries) {
        try {
            return await fn();
        } catch (error) {
            attempt++;
            const delay = Math.pow(2, attempt) * 1000;
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
    throw new Error('Max retries exceeded');
}
```

**131.** Timeout handling prevents operations from hanging indefinitely, which would block workers and waste resources. It ensures the system remains responsive.

**132.** Optimal concurrency depends on:
- Available CPU cores
- Available memory
- Task type (CPU vs I/O bound)
- System load
- Network conditions

#### Module 3.2

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 133 | B | 137 | A |
| 134 | B | 138 | A |
| 135 | C | 139 | B |
| 136 | B | 140 | B |

**141.** Key resources to monitor:
- Memory usage (total, used, free)
- CPU usage (load, per-core)
- File handles (open, max)
- Network connections
- Disk I/O

**142.** Memory-aware scheduling:
1. Monitor memory usage
2. If memory > 80%, reduce concurrency
3. If memory < 50%, increase concurrency
4. Use thresholds to adapt

**143.** Higher concurrency generally means higher memory usage as more operations are active simultaneously. The relationship depends on the size of each operation's memory footprint.

**144.** When memory is low:
1. Reduce concurrency
2. Pause background tasks
3. Clear caches
4. Complete critical tasks first
5. Send alerts
6. Gracefully degrade

#### Module 3.3

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 145 | B | 149 | B |
| 146 | D | 150 | A |
| 147 | A | 151 | D |
| 148 | A | 152 | C |

**153.** Priority levels:
- CRITICAL: Security patches, must process immediately
- HIGH: Production packages, process quickly
- MEDIUM: Development packages, normal processing
- LOW: Optional packages, process when available
- BACKGROUND: Non-critical, process when idle

**154.** Priority inversion occurs when a low-priority item blocks a high-priority item. Prevention techniques include priority aging (increasing priority over time) and using separate queues.

**155.** Priority aging:
1. Track when items were added
2. If item waits beyond threshold, promote to higher priority
3. Implement with increasing priority levels
4. Log promotions for audit

**156.** Critical packages (security patches, known vulnerabilities) must be processed first to prevent exploitation. Delaying critical package analysis increases security risk.

#### Module 3.4

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 157 | B | 162 | B |
| 158 | B | 163 | A |
| 159 | B | 164 | B |
| 160 | B | 165 | B |
| 161 | C | 166 | A |

**167.** A concurrent scanner architecture:
1. Queue of packages to scan
2. Worker pool with configurable concurrency
3. Resource manager monitoring system usage
4. Priority queuing for critical packages
5. Streaming results for real-time feedback
6. Error handling with retry logic
7. Graceful degradation under load

**168.** These components work together:
- Concurrency Controller: Manages parallel processing
- Resource Manager: Prevents resource exhaustion
- Priority Queue: Ensures critical items first
- Together they provide efficient, reliable processing

**169.** Graceful degradation:
1. Detect resource pressure
2. Reduce concurrency
3. Pause non-critical tasks
4. Complete critical tasks
5. Alert operations
6. Recover when resources available

### Phase 4 Answer Key

#### Module 4.1

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 170 | B | 174 | B |
| 171 | C | 175 | B |
| 172 | B | 176 | B |
| 173 | A | 177 | B |

**178.** AI should never be the authoritative decision-maker because:
- AI is probabilistic, not deterministic
- AI can hallucinate or be wrong
- Security requires deterministic guarantees
- Need for auditability and accountability
- AI can be manipulated (prompt injection)

**179.** Output validation ensures:
- Data is in the expected format
- Required fields are present
- Values are within allowed ranges
- No malformed data enters the system
- Automated processing is reliable

**180.** When AI response is malformed:
1. Log the error
2. Use fallback analysis
3. Retry with different prompt
4. Alert administrators
5. Continue with deterministic policies

**181.** System prompt defines the AI's role, constraints, and behavior. Task prompt describes the specific analysis task and output format. System prompt is static; task prompt varies with input.

#### Module 4.2

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 182 | B | 186 | B |
| 183 | B | 187 | B |
| 184 | A | 188 | B |
| 185 | B | 189 | B |

**190.** Key components of a security prompt:
1. System prompt (role, constraints)
2. Task description (what to analyze)
3. Data context (package details)
4. Output schema (expected format)
5. Examples (few-shot learning)
6. Error handling instructions

**191.** Few-shot learning for security:
1. Provide 2-3 examples of well-formatted analyses
2. Show different risk levels and outputs
3. Demonstrate correct JSON format
4. Help AI understand expected response style

**192.** Chain-of-thought prompts ask for reasoning steps before the final answer. Standard prompts ask for the final answer directly. Chain-of-thought improves accuracy for complex tasks.

**193.** Adapting prompts for risk levels:
- CRITICAL: Focus on immediate threats, block actions
- HIGH: Focus on urgent remediation
- MEDIUM: Focus on scheduled fixes
- LOW: Focus on monitoring

#### Module 4.3

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 194 | B | 198 | B |
| 195 | C | 199 | B |
| 196 | B | 200 | B |
| 197 | B | 201 | B |

**202.** GitHub Actions integration:
1. Create workflow file (.github/workflows/security-scan.yml)
2. Trigger on push, PR, schedule
3. Set up Node.js
4. Install dependencies
5. Run security scan
6. Create check run or status
7. Fail build on critical findings

**203.** Check runs provide detailed feedback with annotations and summaries. Status checks provide simple pass/fail indicators. Check runs are more detailed and user-friendly.

**204.** Severity-based notifications:
- CRITICAL: Slack + Email immediately
- HIGH: Slack within 1 hour
- MEDIUM: Email daily summary
- LOW: Weekly report

**205.** Alert notifications should include:
- Severity level
- Package name and version
- Issue description
- Action required
- Recommended fix
- Link to full report
- Timestamp

#### Module 4.4

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 206 | B | 211 | A |
| 207 | B | 212 | B |
| 208 | B | 213 | B |
| 209 | B | 214 | B |
| 210 | B | 215 | D |

**216.** AI-augmented security pipeline:
1. Package data → LLM Service → Analysis
2. Schema Validator → Validate output
3. Policy Engine → Apply rules
4. CI/CD Integration → Block/Allow
5. Notification Service → Alert team

**217.** "AI recommends, policies decide, humans override":
- AI provides analysis and recommendations
- Policies enforce deterministic rules
- Humans can override policies with justification
- Example: AI recommends blocking package, policy blocks, human can override with approval

**218.** AI failure fallback strategy:
1. Detect failure (timeout, error, invalid output)
2. Log the failure
3. Use fallback analysis (simplified)
4. Apply stricter policies
5. Alert administrators
6. Continue processing

### Primers Answer Key

#### Primer 1

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 219 | B | 224 | C |
| 220 | B | 225 | A |
| 221 | B | 226 | B |
| 222 | B | 227 | B |
| 223 | A | 228 | C |

**229.** `dependencies` are required for production use and are installed in production. `devDependencies` are only needed for development and testing and are not installed in production.

**230.** The lock file records exact versions installed and integrity hashes. It ensures deterministic builds and prevents tampering by verifying package contents.

**231.** Before installing:
1. Review package.json scripts
2. Check for suspicious dependencies
3. Verify maintainer trust
4. Check download statistics
5. Review source code if available
6. Run security scanner

**232.** Lifecycle scripts execute with user permissions and can perform malicious actions. Reviewing scripts helps detect and prevent attacks.

**233.** The `prepare` script runs during installation and publishing, giving it broad execution opportunities. It can be used for both legitimate setup and malicious actions.

#### Primer 2

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 234 | A | 239 | D |
| 235 | B | 240 | B |
| 236 | C | 241 | B |
| 237 | A | 242 | B |
| 238 | C | 243 | A |

**244.** `^1.2.3` allows patch and minor updates (>=1.2.3 <2.0.0). `~1.2.3` only allows patch updates (>=1.2.3 <1.3.0). Caret is more permissive.

**245.** `dependencies` are required for the package to work. `peerDependencies` are required by the host package and are not installed by the package itself.

**246.** npm resolves conflicts by:
1. Finding versions that satisfy all requirements
2. Installing different versions for different dependencies if needed
3. Using the most suitable version based on semver rules

**247.** Exact versions ensure consistent installations across environments and prevent unexpected breaking changes from updates.

**248.** package.json defines version ranges; package-lock.json records exact versions installed. package-lock.json takes precedence during installation when present.

#### Primer 3

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 249 | B | 254 | A |
| 250 | A | 255 | B |
| 251 | B | 256 | B |
| 252 | A | 257 | A |
| 253 | A | 258 | A |

**259.** Private registry benefits:
- Controlled access
- Internal package availability
- Registry security control
- Compliance enforcement
- Reduced public exposure

**260.** Registry verifies integrity through:
- SHA512 integrity hashes
- Package signatures
- SSL/TLS encryption
- Registry security controls

**261.** Authentication verifies identity (who you are). Authorization verifies permissions (what you can do). Both are required for secure registry access.

**262.** Detect typosquatting by:
- Comparing names to popular packages
- Using Levenshtein distance
- Checking for suspicious patterns
- Monitoring download statistics
- Using security tools

**263.** Risks of public registries for internal packages:
- Dependency confusion attacks
- Data exposure
- Intellectual property theft
- Supply chain compromise

#### Primer 4

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 264 | A | 269 | A |
| 265 | A | 270 | A |
| 266 | A | 271 | A |
| 267 | A | 272 | A |
| 268 | B | 273 | A |

**274.** Prototype pollution modifies Object.prototype, affecting all objects. It can be exploited to override methods, inject properties, or bypass security checks.

**275.** Three types of XSS:
- Reflected XSS: script injected through URL parameters
- Stored XSS: script stored in database
- DOM-based XSS: script in client-side code

**276.** `eval` executes arbitrary JavaScript code, making it dangerous when handling user input. It bypasses normal security controls.

**277.** Secure file path operations:
1. Normalize paths with path.resolve
2. Validate path is within intended directory
3. Check file permissions
4. Use path.basename for filenames

**278.** `exec` runs commands through a shell, allowing command injection. `execFile` runs commands directly without a shell, reducing injection risk.

#### Primer 5

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 279 | A | 284 | A |
| 280 | A | 285 | A |
| 281 | A | 286 | A |
| 282 | A | 287 | A |
| 283 | A | 288 | A |

**289.** Most common supply chain attacks:
- Typosquatting
- Dependency confusion
- Malicious lifecycle scripts
- Version hijacking
- Maintainer compromise

**290.** Detect typosquatting:
- Name similarity algorithms
- Pattern matching
- Popular package lists
- Download statistics monitoring
- Registry scanning

**291.** Typosquatting uses similar names to popular packages. Dependency confusion publishes public versions of private packages. Both are supply chain attacks with different vectors.

**292.** Detect malicious scripts:
- Pattern matching for dangerous operations
- AST analysis
- Shell command detection
- Network access detection
- Environment variable monitoring

**293.** Signs of maintainer compromise:
- Unusual login locations
- Unexpected package versions
- New maintainers added
- Suspicious code changes
- Account activity anomalies

### Final Comprehensive Exam Answer Key

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 294 | C | 319 | A |
| 295 | B | 320 | A |
| 296 | B | 321 | B |
| 297 | C | 322 | B |
| 298 | B | 323 | C |
| 299 | B | 324 | C |
| 300 | B | 325 | A |
| 301 | B | 326 | A |
| 302 | B | 327 | B |
| 303 | C | 328 | A |
| 304 | B | 329 | B |
| 305 | B | 330 | B |
| 306 | A | 331 | A |
| 307 | B | 332 | B |
| 308 | B | 333 | B |
| 309 | B | 334 | B |
| 310 | A | 335 | A |
| 311 | C | 336 | B |
| 312 | B | 337 | B |
| 313 | A | 338 | D |
| 314 | B | 339 | B |
| 315 | A | 340 | B |
| 316 | A | 341 | A |
| 317 | B | 342 | B |
| 318 | A | 343 | B |

---

## ANSWER KEY: ESSAY QUESTIONS

### Question 344: npm Install Lifecycle

**Model Answer:**

The npm install lifecycle consists of multiple phases, each with security implications:

**Phase 1: preinstall**
- Runs before the package is installed
- Can execute arbitrary code with user permissions
- Security risk: HIGH - Runs before any security checks

**Phase 2: install**
- Runs during package installation
- Full execution with user permissions
- Security risk: CRITICAL - During installation with full access

**Phase 3: postinstall**
- Runs after package installation
- Most common attack vector
- Security risk: CRITICAL - After installation, less likely to be monitored

**Phase 4: preuninstall/uninstall/postuninstall**
- Runs during uninstallation
- Can prevent removal
- Security risk: MEDIUM

**Phase 5: prepare**
- Runs on install and publish
- Security risk: HIGH

**Security Implications:**
- Scripts have full user permissions
- Can access filesystem, network, environment
- Can execute arbitrary commands
- Can install backdoors
- Can exfiltrate data

**Mitigation Strategies:**
- Use --ignore-scripts
- Review scripts before installing
- Use security scanners
- Implement policy controls

### Question 345: JavaScript Event Loop Exploitation

**Model Answer:**

**Event Loop Overview:**
- Single-threaded with non-blocking I/O
- Call stack for synchronous execution
- Microtask queue (process.nextTick, Promise.then, queueMicrotask)
- Macrotask queue (setTimeout, setInterval, I/O operations)
- Event loop processes microtasks before macrotasks

**Exploitation Vectors:**

1. **process.nextTick Hijacking**
   - Highest priority execution
   - Runs immediately after call stack clears
   - Can execute before any other async operations
   - Example: Stealing environment variables immediately

2. **Promise.then Exploitation**
   - Microtask priority
   - Runs before setTimeout
   - Can hide malicious activity among legitimate promises
   - Example: Data exfiltration in promise chain

3. **setTimeout Evasion**
   - Delayed execution
   - Runs after all microtasks
   - Appears less suspicious
   - Example: Delayed backdoor installation

4. **Event Loop Starvation**
   - Block the event loop with synchronous operations
   - Denial of service
   - Example: Infinite loop or heavy computation

**Detection Methods:**
- AST analysis for suspicious patterns
- Runtime monitoring
- Behavioral analysis
- Pattern matching

### Question 346: Socket vs. Snyk Comparison

**Model Answer:**

**Socket:**

**Strengths:**
- Behavioral analysis
- Supply chain security focus
- Zero-day threat detection
- Capability-based risk assessment
- Typosquatting detection
- Dependency confusion detection
- Real-time risk assessment

**Weaknesses:**
- Limited CVE coverage
- Newer, less established
- Smaller community

**Snyk:**

**Strengths:**
- Comprehensive CVE coverage
- Detailed remediation advice
- Established platform
- Extensive integrations
- IDE integration
- Large community

**Weaknesses:**
- Limited behavioral analysis
- Less focus on supply chain attacks
- Primarily vulnerability-focused

**When to Use:**

**Use Socket:**
- Evaluating new packages
- Supply chain security concerns
- Behavioral analysis needed
- Zero-day threat protection
- Dependency approval processes

**Use Snyk:**
- Managing existing dependencies
- Known vulnerability management
- Compliance requirements
- Remediation guidance needed
- Integration with existing tools

**Best Practice:**
Use both tools for comprehensive coverage. Socket catches unknown threats, Snyk catches known vulnerabilities.

### Question 347: Supply Chain Attack Types

**Model Answer:**

**1. Typosquatting**
- Attack: Publishing packages with similar names to popular packages
- Examples: expreess (express), loash (lodash), reactt (react)
- Detection: Name similarity algorithms, pattern matching
- Impact: Users accidentally install malicious packages

**2. Dependency Confusion**
- Attack: Publishing public versions of internal package names
- Examples: internal-utils@999.0.0 on public registry
- Detection: Check private packages with unscoped dependencies
- Impact: Malicious code in internal applications

**3. Malicious Install Scripts**
- Attack: Using lifecycle scripts (preinstall, postinstall) for attacks
- Examples: Data exfiltration, backdoor installation
- Detection: Pattern matching, behavioral analysis
- Impact: Full system compromise

**4. Version Hijacking**
- Attack: Publishing malicious versions of existing packages
- Examples: Malicious patch versions
- Detection: Integrity verification, version history
- Impact: Compromised legitimate packages

**5. Maintainer Compromise**
- Attack: Stealing maintainer credentials
- Examples: Phishing, credential theft
- Detection: Account activity monitoring
- Impact: Legitimate packages compromised

**6. Protestware**
- Attack: Packages with political content
- Examples: node-ipc, colors.js
- Detection: Code analysis, maintainer activity
- Impact: Application disruption

**Detection Strategies:**
- Behavioral analysis
- Capability scanning
- Integrity verification
- Maintainer monitoring
- Registry monitoring
- AI-assisted analysis

### Question 348: Concurrent Scanner Architecture

**Model Answer:**

**Components:**

**1. Priority Queue**
- Multiple priority levels (CRITICAL, HIGH, MEDIUM, LOW, BACKGROUND)
- Priority aging to prevent starvation
- Tracking of wait times

**2. Concurrency Controller**
- Worker pool pattern
- Configurable concurrency
- Timeout handling
- Cancellation support
- Retry logic with backoff

**3. Resource Manager**
- Memory usage monitoring
- CPU usage monitoring
- File handle monitoring
- Health checks
- Graceful degradation

**4. Streaming Results**
- Real-time result streaming
- Buffer management
- Multiple output formats
- Progress tracking

**5. Error Handling**
- Retry logic with exponential backoff
- Graceful failure handling
- Error logging
- Alerting

**Flow:**
1. Items added to priority queue
2. Workers pull items based on priority
3. Resource manager ensures resources available
4. Items processed with timeout
5. Results streamed in real-time
6. Errors handled with retries
7. Status tracked and reported

**Scaling:**
- Horizontal: Multiple instances
- Vertical: More resources
- Adaptive: Adjust concurrency based on load
- Distributed: Across multiple machines

### Question 349: AST-Based Capability Scanning

**Model Answer:**

**What is AST Analysis?**
- Abstract Syntax Tree represents code structure
- Trees of nodes representing code elements
- Analyzes without executing code

**Process:**

**1. Parsing:**
- Convert source code to AST using parser (@babel/parser)
- Parse JavaScript, TypeScript, JSX
- Handle different file types

**2. Traversal:**
- Walk through AST nodes
- Identify patterns of interest
- Check for dangerous operations

**3. Detection:**
- Shell execution: child_process.exec, spawn
- Network access: http.get, axios, fetch
- Filesystem access: fs.readFile, writeFile
- Environment access: process.env
- Dynamic code: eval, new Function, vm

**4. Risk Scoring:**
- Severity of capability (CRITICAL, HIGH, MEDIUM, LOW)
- Context of usage
- Frequency of occurrences
- Combined risk score

**Why It's Effective:**
- Safe (no code execution)
- Complete coverage (all files)
- Accurate (no false positives)
- Consistent (deterministic)
- Fast (no runtime overhead)

**Example:**
```
Code: exec('rm -rf /tmp/*')
AST: CallExpression →
  MemberExpression (exec) →
  StringLiteral ('rm -rf /tmp/*')
Detection: SHELL_EXECUTION (CRITICAL)
```

### Question 350: Role of AI in Security

**Model Answer:**

**AI Augments, Not Replaces:**

**AI Capabilities:**
- Analyzes thousands of packages quickly
- Identifies patterns and anomalies
- Generates human-readable explanations
- Prioritizes and triages findings
- Provides context-aware analysis
- Assists incident investigations

**Human Capabilities:**
- Contextual understanding
- Business and strategic decisions
- Complex policy enforcement
- Ethical judgment
- Accountability

**Why AI Should NOT Be the Authority:**

1. **Probabilistic Nature**
   - AI is not deterministic
   - Can hallucinate
   - Confidence levels vary

2. **Security Risks**
   - Prompt injection attacks
   - Adversarial inputs
   - Model bias

3. **Accountability**
   - Cannot be held accountable
   - Decisions need justification
   - Audit requirements

4. **Policy Enforcement**
   - Policies must be deterministic
   - Consistent application required
   - Legal compliance needs

**The "AI Recommends, Policies Decide, Humans Override" Model:**
1. AI generates recommendations
2. Policies evaluate and decide
3. Humans can override with justification
4. All decisions logged and auditable

**Best Practices:**
- Always validate AI output
- Implement fallback strategies
- Monitor AI performance
- Regular prompt refinement
- Human oversight for critical decisions

### Question 351: Policy Engine

**Model Answer:**

**Policy Engine Overview:**
- Enforces deterministic security rules
- Evaluates AI recommendations against policies
- Makes consistent decisions
- Audits all decisions

**Policy Types:**

**1. Risk Level Policies:**
```
CRITICAL → BLOCK (No override)
HIGH → REVIEW (Override with justification)
MEDIUM → REVIEW (Override with justification)
LOW → APPROVE (No override)
```

**2. Capability Policies:**
```
SHELL_EXECUTION → BLOCK (No override)
DYNAMIC_CODE → BLOCK (No override)
FILESYSTEM_ACCESS → REVIEW (Override possible)
NETWORK_ACCESS → REVIEW (Override possible)
```

**3. Vulnerability Policies:**
```
CRITICAL → BLOCK (No override)
HIGH → REVIEW (Override possible)
```

**Relationship with AI:**
- AI provides recommendations
- Policy engine makes decisions
- Human overrides policy decisions

**Decision Flow:**
1. Input: Scan Results + AI Analysis
2. Evaluate against policies
3. Determine action (APPROVE, REVIEW, BLOCK)
4. Execute action
5. Log decision
6. Notify team

**Override Process:**
1. Request override
2. Justification required
3. Administrator approval
4. Timestamped and logged
5. Audit trail maintained

### Question 352: CI/CD Integration

**Model Answer:**

**Integration Flow:**

**1. Trigger Events**
- Push to branch
- Pull request
- Scheduled scan
- Manual trigger

**2. Security Scan**
- Run package analysis
- Check dependencies
- Detect vulnerabilities
- Generate report

**3. Policy Check**
- Evaluate against policies
- Determine risk level
- Generate recommendations

**4. Decision**
- APPROVE: Continue pipeline
- REVIEW: Manual intervention required
- BLOCK: Fail the build

**5. Notifications**
- Slack alerts
- Email reports
- Team notifications

**6. Reporting**
- JSON reports
- HTML reports
- Markdown reports
- GitHub check runs

**GitHub Actions Integration:**
```yaml
name: Security Scan
on: [push, pull_request]
jobs:
  scan:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm install
      - run: node ci-cd-integration.js --mode ci
      - uses: actions/upload-artifact@v4
        with:
          name: security-report
          path: security-report.json
```

**Best Practices:**
- Run scans automatically
- Block builds on critical issues
- Notify teams of findings
- Provide clear feedback
- Maintain audit logs
- Regular policy reviews

### Question 353: Security Prompt Components

**Model Answer:**

**1. System Prompt**
```
Role: "You are a senior security engineer specializing in supply chain security..."
Constraints: "Never recommend insecure solutions..."
Style: "Be precise and technical..."
```

**2. Task Prompt**
```
Goal: "Analyze the security of this package..."
Scope: "Consider capabilities, vulnerabilities, and supply chain risks..."
Output: "Return a structured JSON report..."
```

**3. Context Prompt**
```
Package Data: { name, version, capabilities, vulnerabilities }
Context: "This is a production dependency..."
Environment: "High-security requirements..."
```

**4. Output Schema**
```
{
  "summary": "string (max 200 chars)",
  "riskLevel": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "riskScore": "number (0-100)",
  "capabilities": "array",
  "vulnerabilities": "array",
  "recommendations": "array"
}
```

**5. Examples (Few-Shot Learning)**
- Provide 2-3 examples of well-formatted responses
- Demonstrate different risk levels
- Show correct JSON structure

**6. Quality Guidelines**
- Always prioritize security
- Never recommend insecure solutions
- Be specific and actionable
- Provide evidence for claims
- Flag uncertainty clearly

**Key Principles:**
- Be specific and structured
- Provide clear examples
- Define constraints explicitly
- Use consistent formatting
- Include error handling guidance

---

## SCORING GUIDES

### Multiple Choice Scoring
- 1 point per correct answer
- No partial credit
- Total possible: Varies by section

### Short Answer Scoring (5 points each)
- 5 points: Complete, correct answer with examples
- 4 points: Good answer, missing minor detail
- 3 points: Adequate answer, missing important detail
- 2 points: Partial answer, significant gaps
- 1 point: Minimal understanding
- 0 points: Incorrect or missing

### Essay Question Scoring (25 points each)
- 25 points: Comprehensive, well-structured, all key points covered
- 20 points: Good coverage, minor gaps
- 15 points: Adequate, some important points missing
- 10 points: Partial coverage, significant gaps
- 5 points: Minimal coverage
- 0 points: Missing or incorrect

---

## TOTAL SCORE CALCULATION

### Phase 1 Total: 100 points
- Module 1.1: 21 questions (21 points)
- Module 1.2: 17 questions (17 points)
- Module 1.3: 16 questions (16 points)
- Module 1.4: 13 questions + 3 essays (46 points)

### Phase 2 Total: 100 points
- Module 2.1: 16 questions (16 points)
- Module 2.2: 16 questions (16 points)
- Module 2.3: 16 questions (16 points)
- Module 2.4: 13 questions + 3 essays (52 points)

### Phase 3 Total: 100 points
- Module 3.1: 16 questions (16 points)
- Module 3.2: 16 questions (16 points)
- Module 3.3: 16 questions (16 points)
- Module 3.4: 13 questions + 3 essays (52 points)

### Phase 4 Total: 100 points
- Module 4.1: 16 questions (16 points)
- Module 4.2: 16 questions (16 points)
- Module 4.3: 16 questions (16 points)
- Module 4.4: 13 questions + 3 essays (52 points)

### Final Comprehensive Exam: 200 points
- Part A: 50 questions (50 points)
- Part B: 10 questions (50 points)
- Part C: 3 questions (100 points)

### Total Course Score: 600 points

### Grade Scale
- A: 540-600 points (90-100%)
- B: 480-539 points (80-89%)
- C: 420-479 points (70-79%)
- D: 360-419 points (60-69%)
- F: Below 360 points (<60%)
