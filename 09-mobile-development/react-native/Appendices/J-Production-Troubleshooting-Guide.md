# Appendix J: Production Troubleshooting Guide

Welcome to Appendix J! This comprehensive guide covers everything you need to know about troubleshooting your React Native app in production. From debugging techniques and crash analysis to performance issue diagnosis and user-reported problems, you'll learn how to identify, diagnose, and resolve issues that arise after deployment.

---

## Table of Contents

1. [Production Monitoring & Alerting](#production-monitoring--alerting)
2. [Crash Analysis & Debugging](#crash-analysis--debugging)
3. [Performance Issue Diagnosis](#performance-issue-diagnosis)
4. [Network & API Troubleshooting](#network--api-troubleshooting)
5. [Device-Specific Issues](#device-specific-issues)
6. [User-Reported Problem Investigation](#user-reported-problem-investigation)
7. [Emergency Response Playbook](#emergency-response-playbook)
8. [Post-Mortem Analysis](#post-mortem-analysis)

---

## Production Monitoring & Alerting

### Complete Monitoring Setup

```typescript
// src/monitoring/ProductionMonitor.ts
import * as Sentry from '@sentry/react-native';
import { Platform, AppState } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Production Monitoring System
 * 
 * This provides comprehensive production monitoring:
 * - Real-time error tracking
 * - Performance metrics
 * - User session tracking
 * - Custom alerts
 * - Health checks
 */

export interface AlertConfig {
  id: string;
  name: string;
  condition: (data: any) => boolean;
  severity: 'info' | 'warning' | 'critical';
  channels: ('email' | 'slack' | 'pagerduty')[];
  cooldown: number; // seconds
}

export class ProductionMonitor {
  private static instance: ProductionMonitor;
  private alerts: Map<string, AlertConfig> = new Map();
  private alertHistory: Map<string, number> = new Map();
  private healthChecks: Map<string, () => Promise<boolean>> = new Map();

  private constructor() {
    this.setupDefaultAlerts();
    this.startHealthChecks();
  }

  static getInstance(): ProductionMonitor {
    if (!ProductionMonitor.instance) {
      ProductionMonitor.instance = new ProductionMonitor();
    }
    return ProductionMonitor.instance;
  }

  /**
   * Setup default alerts
   */
  private setupDefaultAlerts() {
    // Crash rate alert
    this.addAlert({
      id: 'crash_rate',
      name: 'High Crash Rate',
      condition: (data) => data.crashRate > 0.05, // 5% crash rate
      severity: 'critical',
      channels: ['slack', 'pagerduty'],
      cooldown: 300, // 5 minutes
    });

    // API error rate alert
    this.addAlert({
      id: 'api_error_rate',
      name: 'High API Error Rate',
      condition: (data) => data.apiErrorRate > 0.10, // 10% error rate
      severity: 'critical',
      channels: ['slack'],
      cooldown: 600, // 10 minutes
    });

    // Performance alert
    this.addAlert({
      id: 'performance_degradation',
      name: 'Performance Degradation',
      condition: (data) => data.avgResponseTime > 3000, // 3 seconds
      severity: 'warning',
      channels: ['slack'],
      cooldown: 1800, // 30 minutes
    });

    // Low session duration
    this.addAlert({
      id: 'low_session_duration',
      name: 'Low Session Duration',
      condition: (data) => data.avgSessionDuration < 30, // 30 seconds
      severity: 'warning',
      channels: ['email'],
      cooldown: 3600, // 1 hour
    });
  }

  /**
   * Add an alert configuration
   */
  addAlert(config: AlertConfig): void {
    this.alerts.set(config.id, config);
  }

  /**
   * Register a health check
   */
  registerHealthCheck(name: string, check: () => Promise<boolean>): void {
    this.healthChecks.set(name, check);
  }

  /**
   * Start periodic health checks
   */
  private startHealthChecks() {
    setInterval(async () => {
      await this.runHealthChecks();
    }, 60000); // Every minute
  }

  /**
   * Run all health checks
   */
  private async runHealthChecks() {
    for (const [name, check] of this.healthChecks) {
      try {
        const result = await check();
        if (!result) {
          this.triggerAlert({
            id: `health_check_${name}`,
            name: `Health Check Failed: ${name}`,
            severity: 'critical',
            data: { name, timestamp: new Date().toISOString() },
          });
        }
      } catch (error) {
        console.error(`Health check failed for ${name}:`, error);
      }
    }
  }

  /**
   * Check all alerts
   */
  checkAlerts(data: any): void {
    for (const [id, config] of this.alerts) {
      try {
        if (config.condition(data)) {
          this.triggerAlert({
            id,
            name: config.name,
            severity: config.severity,
            data,
          });
        }
      } catch (error) {
        console.error(`Alert check failed for ${id}:`, error);
      }
    }
  }

  /**
   * Trigger an alert
   */
  private triggerAlert(params: {
    id: string;
    name: string;
    severity: 'info' | 'warning' | 'critical';
    data: any;
  }): void {
    const { id, name, severity, data } = params;
    
    // Check cooldown
    const lastTriggered = this.alertHistory.get(id);
    if (lastTriggered) {
      const config = this.alerts.get(id);
      if (config && (Date.now() - lastTriggered) / 1000 < config.cooldown) {
        return; // Still in cooldown period
      }
    }

    // Update history
    this.alertHistory.set(id, Date.now());

    // Log alert
    console.warn(`🔔 Alert: ${name} (${severity})`, data);

    // Send to monitoring service
    Sentry.addBreadcrumb({
      category: 'alert',
      message: name,
      level: severity === 'critical' ? 'fatal' : severity,
      data,
    });

    // Send notifications
    this.sendAlertNotification({ id, name, severity, data });
  }

  /**
   * Send alert notifications
   */
  private sendAlertNotification(params: {
    id: string;
    name: string;
    severity: 'info' | 'warning' | 'critical';
    data: any;
  }): void {
    // In production, send to Slack, email, PagerDuty, etc.
    console.log(`📧 Sending ${params.severity} alert: ${params.name}`);
  }
}

export const productionMonitor = ProductionMonitor.getInstance();
```

---

## Crash Analysis & Debugging

### Comprehensive Crash Analysis Tool

```typescript
// src/debugging/CrashAnalyzer.ts
import * as Sentry from '@sentry/react-native';
import { Platform } from 'react-native';

/**
 * Crash Analysis & Debugging
 * 
 * This provides comprehensive crash analysis:
 * - Crash log parsing
 * - Stack trace analysis
 * - Symbolication
 * - Pattern detection
 * - Root cause analysis
 */

export interface CrashReport {
  id: string;
  timestamp: string;
  platform: 'ios' | 'android';
  appVersion: string;
  osVersion: string;
  deviceModel: string;
  error: {
    name: string;
    message: string;
    stack: string[];
  };
  context: {
    user?: string;
    session?: string;
    screen?: string;
    action?: string;
  };
  breadcrumbs: Array<{
    timestamp: string;
    category: string;
    message: string;
    data?: any;
  }>;
}

export class CrashAnalyzer {
  private static instance: CrashAnalyzer;
  private crashReports: Map<string, CrashReport> = new Map();
  private patterns: Map<string, number> = new Map();

  private constructor() {}

  static getInstance(): CrashAnalyzer {
    if (!CrashAnalyzer.instance) {
      CrashAnalyzer.instance = new CrashAnalyzer();
    }
    return CrashAnalyzer.instance;
  }

  /**
   * Capture a crash report
   */
  captureCrash(report: CrashReport): void {
    this.crashReports.set(report.id, report);
    this.analyzeCrash(report);
  }

  /**
   * Analyze a crash report
   */
  private analyzeCrash(report: CrashReport): {
    severity: 'critical' | 'high' | 'medium' | 'low';
    probableCause: string;
    affectedUsers: number;
    suggestedFix: string;
  } {
    // Analyze error type
    const errorType = this.detectErrorType(report);
    const stackAnalysis = this.analyzeStack(report.error.stack);
    const pattern = this.detectPattern(report);

    // Determine severity
    let severity: 'critical' | 'high' | 'medium' | 'low' = 'medium';
    if (errorType === 'Fatal' || errorType === 'Memory') {
      severity = 'critical';
    } else if (pattern === 'Multiple' || pattern === 'Growth') {
      severity = 'high';
    }

    // Generate suggested fix
    const suggestedFix = this.suggestFix(report);

    return {
      severity,
      probableCause: this.identifyRootCause(report),
      affectedUsers: this.estimateAffectedUsers(report),
      suggestedFix,
    };
  }

  /**
   * Detect error type
   */
  private detectErrorType(report: CrashReport): string {
    const message = report.error.message.toLowerCase();
    
    if (message.includes('out of memory') || message.includes('oom')) {
      return 'Memory';
    }
    if (message.includes('null') || message.includes('undefined')) {
      return 'NullReference';
    }
    if (message.includes('permission')) {
      return 'Permission';
    }
    if (message.includes('network') || message.includes('timeout')) {
      return 'Network';
    }
    if (message.includes('react') || message.includes('render')) {
      return 'Render';
    }
    
    return 'Unknown';
  }

  /**
   * Analyze stack trace
   */
  private analyzeStack(stack: string[]): {
    firstFrame: string;
    nativeFrames: number;
    reactFrames: number;
  } {
    let nativeFrames = 0;
    let reactFrames = 0;
    let firstFrame = stack[0] || '';

    for (const frame of stack) {
      if (frame.includes('NativeModules') || frame.includes('RCT')) {
        nativeFrames++;
      } else if (frame.includes('react') || frame.includes('ReactNative')) {
        reactFrames++;
      }
    }

    return { firstFrame, nativeFrames, reactFrames };
  }

  /**
   * Detect pattern in crashes
   */
  private detectPattern(report: CrashReport): string {
    const key = `${report.error.name}:${report.error.message}`;
    const count = (this.patterns.get(key) || 0) + 1;
    this.patterns.set(key, count);

    if (count > 10) {
      return 'HighFrequency';
    } else if (count > 5) {
      return 'Repeating';
    } else if (count > 2) {
      return 'Multiple';
    }
    return 'Single';
  }

  /**
   * Identify root cause
   */
  private identifyRootCause(report: CrashReport): string {
    // In production, use AI/ML for root cause analysis
    // For demo, return a placeholder
    const errorType = this.detectErrorType(report);
    const { firstFrame } = this.analyzeStack(report.error.stack);
    
    return `Possible ${errorType} error in ${firstFrame}`;
  }

  /**
   * Estimate affected users
   */
  private estimateAffectedUsers(report: CrashReport): number {
    // In production, query analytics for user count
    return Math.floor(Math.random() * 100) + 1;
  }

  /**
   * Suggest fix
   */
  private suggestFix(report: CrashReport): string {
    const errorType = this.detectErrorType(report);
    
    switch (errorType) {
      case 'Memory':
        return 'Consider using FlatList with virtualization, reduce image sizes, or implement lazy loading';
      case 'NullReference':
        return 'Add null checks or default values for the undefined property';
      case 'Permission':
        return 'Ensure permissions are requested and handled properly';
      case 'Network':
        return 'Implement retry logic, add timeout handling, or improve error recovery';
      default:
        return 'Review the stack trace and add appropriate error handling';
    }
  }

  /**
   * Generate crash report summary
   */
  generateSummary(report: CrashReport): string {
    const analysis = this.analyzeCrash(report);
    
    let summary = `# Crash Report Summary\n\n`;
    summary += `**ID:** ${report.id}\n`;
    summary += `**Timestamp:** ${report.timestamp}\n`;
    summary += `**Platform:** ${report.platform}\n`;
    summary += `**Version:** ${report.appVersion}\n`;
    summary += `**Device:** ${report.deviceModel}\n`;
    summary += `**Severity:** ${analysis.severity}\n\n`;
    summary += `## Error\n`;
    summary += `${report.error.name}: ${report.error.message}\n\n`;
    summary += `## Root Cause\n`;
    summary += `${analysis.probableCause}\n\n`;
    summary += `## Suggested Fix\n`;
    summary += `${analysis.suggestedFix}\n\n`;
    summary += `## Stack Trace\n`;
    summary += `\`\`\`\n${report.error.stack.join('\n')}\n\`\`\`\n`;
    
    return summary;
  }

  /**
   * Send crash report to developers
   */
  sendCrashReport(report: CrashReport): void {
    const summary = this.generateSummary(report);
    
    // In production, send to Slack, email, or PagerDuty
    console.log(`📧 Sending crash report for ${report.id}:\n${summary}`);
  }
}

export const crashAnalyzer = CrashAnalyzer.getInstance();
```

---

## Performance Issue Diagnosis

### Performance Diagnostic Tool

```typescript
// src/debugging/PerformanceDiagnostic.ts
import { Performance } from 'react-native-performance';
import { Platform } from 'react-native';

/**
 * Performance Diagnostic Tool
 * 
 * This provides comprehensive performance diagnosis:
 * - Frame rate analysis
 * - Memory usage tracking
 * - Render performance
 * - Network timing
 * - Battery impact
 */

export interface PerformanceProfile {
  fps: number;
  memory: {
    used: number;
    total: number;
    percentage: number;
  };
  cpu: {
    user: number;
    system: number;
    total: number;
  };
  network: {
    requests: number;
    totalTime: number;
    avgTime: number;
  };
  render: {
    componentCount: number;
    renderTime: number;
    updateTime: number;
  };
}

export class PerformanceDiagnostic {
  private static instance: PerformanceDiagnostic;
  private profiles: PerformanceProfile[] = [];
  private frameTimings: number[] = [];

  private constructor() {}

  static getInstance(): PerformanceDiagnostic {
    if (!PerformanceDiagnostic.instance) {
      PerformanceDiagnostic.instance = new PerformanceDiagnostic();
    }
    return PerformanceDiagnostic.instance;
  }

  /**
   * Start performance profiling
   */
  startProfiling(): void {
    this.profiles = [];
    this.frameTimings = [];
    this.measureFrameRate();
    this.measureMemoryUsage();
  }

  /**
   * Measure frame rate
   */
  private measureFrameRate(): void {
    let lastFrameTime = performance.now();
    let frameCount = 0;
    
    const measure = () => {
      const now = performance.now();
      const delta = now - lastFrameTime;
      
      if (delta > 0) {
        this.frameTimings.push(delta);
        const fps = 1000 / delta;
        
        if (fps < 30) {
          console.warn(`⚠️ Low FPS detected: ${fps.toFixed(1)}`);
        }
      }
      
      lastFrameTime = now;
      requestAnimationFrame(measure);
    };
    
    measure();
  }

  /**
   * Measure memory usage
   */
  private measureMemoryUsage(): void {
    setInterval(() => {
      // @ts-ignore - Memory info
      if (global.performance?.memory) {
        // @ts-ignore
        const { usedJSHeapSize, totalJSHeapSize } = global.performance.memory;
        const used = usedJSHeapSize / (1024 * 1024);
        const total = totalJSHeapSize / (1024 * 1024);
        
        if (used / total > 0.8) {
          console.warn(`⚠️ High memory usage: ${used.toFixed(1)}MB / ${total.toFixed(1)}MB`);
        }
      }
    }, 5000);
  }

  /**
   * Get performance profile
   */
  getPerformanceProfile(): PerformanceProfile {
    const avgFPS = this.calculateAverageFPS();
    const memory = this.getMemoryInfo();
    const render = this.getRenderInfo();
    const network = this.getNetworkInfo();
    
    return {
      fps: avgFPS,
      memory,
      cpu: {
        user: 0,
        system: 0,
        total: 0,
      },
      network,
      render,
    };
  }

  /**
   * Calculate average FPS
   */
  private calculateAverageFPS(): number {
    if (this.frameTimings.length === 0) return 60;
    
    const sum = this.frameTimings.reduce((a, b) => a + b, 0);
    const avg = sum / this.frameTimings.length;
    return 1000 / avg;
  }

  /**
   * Get memory info
   */
  private getMemoryInfo(): { used: number; total: number; percentage: number } {
    // @ts-ignore - Memory info
    if (global.performance?.memory) {
      // @ts-ignore
      const { usedJSHeapSize, totalJSHeapSize } = global.performance.memory;
      const used = usedJSHeapSize / (1024 * 1024);
      const total = totalJSHeapSize / (1024 * 1024);
      
      return {
        used,
        total,
        percentage: used / total,
      };
    }
    
    return { used: 0, total: 0, percentage: 0 };
  }

  /**
   * Get render info
   */
  private getRenderInfo(): {
    componentCount: number;
    renderTime: number;
    updateTime: number;
  } {
    // In production, use React DevTools profiler API
    return {
      componentCount: 0,
      renderTime: 0,
      updateTime: 0,
    };
  }

  /**
   * Get network info
   */
  private getNetworkInfo(): {
    requests: number;
    totalTime: number;
    avgTime: number;
  } {
    // In production, track network requests
    return {
      requests: 0,
      totalTime: 0,
      avgTime: 0,
    };
  }

  /**
   * Generate performance report
   */
  generateReport(): string {
    const profile = this.getPerformanceProfile();
    
    let report = `# Performance Diagnostic Report\n\n`;
    report += `**Timestamp:** ${new Date().toISOString()}\n`;
    report += `**Platform:** ${Platform.OS}\n\n`;
    report += `## Frame Rate\n`;
    report += `FPS: ${profile.fps.toFixed(1)}\n\n`;
    report += `## Memory\n`;
    report += `Used: ${profile.memory.used.toFixed(1)}MB\n`;
    report += `Total: ${profile.memory.total.toFixed(1)}MB\n`;
    report += `Usage: ${(profile.memory.percentage * 100).toFixed(1)}%\n\n`;
    report += `## Recommendations\n`;
    
    if (profile.fps < 30) {
      report += `- 🔴 Low frame rate detected. Consider optimizing animations and reducing render load.\n`;
    }
    if (profile.memory.percentage > 0.7) {
      report += `- 🔴 High memory usage. Consider implementing memory management strategies.\n`;
    }
    
    return report;
  }
}

export const performanceDiagnostic = PerformanceDiagnostic.getInstance();
```

---

## Emergency Response Playbook

### Incident Response Plan

```typescript
// src/debugging/IncidentResponse.ts
/**
 * Emergency Response Playbook
 * 
 * This provides a structured incident response plan:
 * - Incident detection
 * - Severity assessment
 * - Response procedures
 * - Communication templates
 * - Resolution tracking
 */

export interface Incident {
  id: string;
  title: string;
  severity: 'SEV1' | 'SEV2' | 'SEV3' | 'SEV4';
  status: 'detected' | 'investigating' | 'resolved' | 'monitoring';
  reportedAt: string;
  assignedTo: string[];
  description: string;
  impact: string;
  steps: string[];
  updates: Array<{
    timestamp: string;
    author: string;
    message: string;
  }>;
}

export class IncidentResponse {
  private static instance: IncidentResponse;
  private incidents: Incident[] = [];
  private onCallEngineers: string[] = [];

  private constructor() {}

  static getInstance(): IncidentResponse {
    if (!IncidentResponse.instance) {
      IncidentResponse.instance = new IncidentResponse();
    }
    return IncidentResponse.instance;
  }

  /**
   * Create an incident
   */
  createIncident(params: {
    title: string;
    severity: 'SEV1' | 'SEV2' | 'SEV3' | 'SEV4';
    description: string;
    impact: string;
  }): Incident {
    const incident: Incident = {
      id: `INC-${Date.now()}`,
      title: params.title,
      severity: params.severity,
      status: 'detected',
      reportedAt: new Date().toISOString(),
      assignedTo: [],
      description: params.description,
      impact: params.impact,
      steps: [],
      updates: [],
    };

    this.incidents.push(incident);
    this.notifyOnCall(incident);
    
    return incident;
  }

  /**
   * Notify on-call engineers
   */
  private notifyOnCall(incident: Incident): void {
    const severityLevels = {
      'SEV1': '🚨 CRITICAL',
      'SEV2': '🔴 HIGH',
      'SEV3': '🟡 MEDIUM',
      'SEV4': '🟢 LOW',
    };

    const message = `
${severityLevels[incident.severity]} Incident: ${incident.title}
ID: ${incident.id}
Impact: ${incident.impact}
Description: ${incident.description}
    `;

    // In production, send to Slack, PagerDuty, etc.
    console.log(`📢 Incident Alert:\n${message}`);
  }

  /**
   * Update an incident
   */
  updateIncident(id: string, update: {
    status?: Incident['status'];
    message: string;
    author: string;
  }): void {
    const incident = this.incidents.find(i => i.id === id);
    if (!incident) return;

    if (update.status) {
      incident.status = update.status;
    }

    incident.updates.push({
      timestamp: new Date().toISOString(),
      author: update.author,
      message: update.message,
    });

    // Notify stakeholders
    this.broadcastUpdate(incident);
  }

  /**
   * Broadcast incident update
   */
  private broadcastUpdate(incident: Incident): void {
    const latestUpdate = incident.updates[incident.updates.length - 1];
    
    const message = `
📢 Incident Update: ${incident.id}
Status: ${incident.status}
Message: ${latestUpdate.message}
Author: ${latestUpdate.author}
    `;

    console.log(`📢 Broadcast:\n${message}`);
  }

  /**
   * Get incident timeline
   */
  getIncidentTimeline(id: string): {
    events: Array<{
      timestamp: string;
      type: 'created' | 'updated' | 'resolved';
      details: any;
    }>;
  } {
    const incident = this.incidents.find(i => i.id === id);
    if (!incident) {
      return { events: [] };
    }

    const events = [];

    // Created event
    events.push({
      timestamp: incident.reportedAt,
      type: 'created',
      details: {
        title: incident.title,
        severity: incident.severity,
        impact: incident.impact,
      },
    });

    // Update events
    incident.updates.forEach(update => {
      events.push({
        timestamp: update.timestamp,
        type: 'updated',
        details: {
          author: update.author,
          message: update.message,
        },
      });
    });

    // Resolved event
    if (incident.status === 'resolved') {
      events.push({
        timestamp: new Date().toISOString(),
        type: 'resolved',
        details: {},
      });
    }

    return { events };
  }

  /**
   * Get incident templates
   */
  getIncidentTemplates(): Record<string, any> {
    return {
      // Template: App Crash
      appCrash: {
        title: 'App Crash on Startup',
        severity: 'SEV1',
        description: 'Users are experiencing crashes when opening the app.',
        impact: '100% of users cannot access the app.',
        steps: [
          'Check crash reporting service (Sentry)',
          'Identify common stack traces',
          'Check recent deployments for changes',
          'Rollback if necessary',
          'Communicate with users',
        ],
      },

      // Template: API Outage
      apiOutage: {
        title: 'API Service Unavailable',
        severity: 'SEV1',
        description: 'The API is returning 500 errors or timing out.',
        impact: 'All app functionality is impacted.',
        steps: [
          'Check API service status',
          'Check server logs for errors',
          'Identify database issues',
          'Scale services if needed',
          'Implement fallback responses',
        ],
      },

      // Template: Performance Degradation
      performanceDegradation: {
        title: 'Performance Degradation',
        severity: 'SEV2',
        description: 'Users are reporting slow app performance.',
        impact: 'User experience is degraded, possible churn.',
        steps: [
          'Check performance metrics',
          'Identify bottlenecks in logs',
          'Review recent code changes',
          'Optimize query performance',
          'Consider caching improvements',
        ],
      },

      // Template: Security Breach
      securityBreach: {
        title: 'Security Breach Detected',
        severity: 'SEV1',
        description: 'Unauthorized access detected in the system.',
        impact: 'User data may be compromised.',
        steps: [
          'Immediately lock down affected systems',
          'Identify breach scope and impact',
          'Notify security team',
          'Rotate all credentials',
          'Communicate with users',
        ],
      },
    };
  }
}

export const incidentResponse = IncidentResponse.getInstance();
```

---

## Post-Mortem Analysis

### Post-Mortem Documentation Template

```typescript
// src/debugging/PostMortem.ts
/**
 * Post-Mortem Analysis
 * 
 * This provides a structured post-mortem template:
 * - Incident summary
 * - Timeline
 * - Root cause analysis
 * - Impact assessment
 * - Action items
 * - Lessons learned
 */

export interface PostMortem {
  id: string;
  incidentId: string;
  title: string;
  date: string;
  summary: string;
  timeline: Array<{
    time: string;
    event: string;
  }>;
  rootCause: {
    description: string;
    contributingFactors: string[];
  };
  impact: {
    usersAffected: number;
    downtime: number;
    dataLoss?: boolean;
    financialImpact?: number;
  };
  actions: Array<{
    item: string;
    owner: string;
    status: 'pending' | 'in-progress' | 'completed';
    priority: 'high' | 'medium' | 'low';
    dueDate: string;
  }>;
  lessons: string[];
}

export class PostMortemManager {
  private static instance: PostMortemManager;
  private postMortems: PostMortem[] = [];

  private constructor() {}

  static getInstance(): PostMortemManager {
    if (!PostMortemManager.instance) {
      PostMortemManager.instance = new PostMortemManager();
    }
    return PostMortemManager.instance;
  }

  /**
   * Create a post-mortem
   */
  createPostMortem(params: {
    incidentId: string;
    title: string;
    summary: string;
    timeline: Array<{ time: string; event: string }>;
    rootCause: { description: string; contributingFactors: string[] };
    impact: {
      usersAffected: number;
      downtime: number;
      dataLoss?: boolean;
      financialImpact?: number;
    };
    actions: Array<{
      item: string;
      owner: string;
      priority: 'high' | 'medium' | 'low';
      dueDate: string;
    }>;
    lessons: string[];
  }): PostMortem {
    const postMortem: PostMortem = {
      id: `PM-${Date.now()}`,
      ...params,
      date: new Date().toISOString(),
      actions: params.actions.map(action => ({
        ...action,
        status: 'pending',
      })),
    };

    this.postMortems.push(postMortem);
    this.distributePostMortem(postMortem);
    
    return postMortem;
  }

  /**
   * Distribute post-mortem to stakeholders
   */
  private distributePostMortem(postMortem: PostMortem): void {
    const message = `
# Post-Mortem: ${postMortem.title}

## Summary
${postMortem.summary}

## Root Cause
${postMortem.rootCause.description}

## Impact
- Users Affected: ${postMortem.impact.usersAffected}
- Downtime: ${postMortem.impact.downtime} minutes

## Action Items
${postMortem.actions.map(a => `- ${a.item} (${a.owner})`).join('\n')}

## Lessons Learned
${postMortem.lessons.map(l => `- ${l}`).join('\n')}
    `;

    // In production, send to team
    console.log(`📄 Post-Mortem:\n${message}`);
  }

  /**
   * Get post-mortem by ID
   */
  getPostMortem(id: string): PostMortem | undefined {
    return this.postMortems.find(pm => pm.id === id);
  }

  /**
   * Get all post-mortems
   */
  getAllPostMortems(): PostMortem[] {
    return this.postMortems;
  }

  /**
   * Update action item status
   */
  updateAction(
    postMortemId: string,
    actionIndex: number,
    status: 'pending' | 'in-progress' | 'completed'
  ): void {
    const postMortem = this.postMortems.find(pm => pm.id === postMortemId);
    if (!postMortem) return;

    if (actionIndex >= 0 && actionIndex < postMortem.actions.length) {
      postMortem.actions[actionIndex].status = status;
    }
  }

  /**
   * Generate post-mortem report
   */
  generateReport(): string {
    if (this.postMortems.length === 0) {
      return 'No post-mortems available.';
    }

    let report = `# Post-Mortem Report\n\n`;
    report += `Total Incidents: ${this.postMortems.length}\n\n`;

    // Group by priority
    const highPriority = this.postMortems.filter(pm => 
      pm.actions.some(a => a.priority === 'high')
    );
    const mediumPriority = this.postMortems.filter(pm => 
      pm.actions.some(a => a.priority === 'medium')
    );
    const lowPriority = this.postMortems.filter(pm => 
      pm.actions.some(a => a.priority === 'low')
    );

    report += `## Incident Summary\n\n`;
    report += `- High Priority Incidents: ${highPriority.length}\n`;
    report += `- Medium Priority Incidents: ${mediumPriority.length}\n`;
    report += `- Low Priority Incidents: ${lowPriority.length}\n\n`;

    report += `## Common Issues\n\n`;
    const commonIssues = this.identifyCommonIssues();
    commonIssues.forEach(issue => {
      report += `- ${issue}\n`;
    });

    return report;
  }

  /**
   * Identify common issues
   */
  private identifyCommonIssues(): string[] {
    const issues: Record<string, number> = {};
    
    this.postMortems.forEach(pm => {
      const cause = pm.rootCause.description;
      issues[cause] = (issues[cause] || 0) + 1;
    });

    // Sort by frequency
    const sorted = Object.entries(issues).sort((a, b) => b[1] - a[1]);
    
    return sorted
      .filter(([_, count]) => count > 1)
      .map(([cause, count]) => `${cause} (${count} occurrences)`);
  }

  /**
   * Export post-mortem as markdown
   */
  exportMarkdown(postMortemId: string): string {
    const postMortem = this.getPostMortem(postMortemId);
    if (!postMortem) return '';

    let markdown = `# Post-Mortem: ${postMortem.title}\n\n`;
    markdown += `**Date:** ${postMortem.date}\n`;
    markdown += `**Incident ID:** ${postMortem.incidentId}\n\n`;
    markdown += `## Summary\n${postMortem.summary}\n\n`;
    markdown += `## Timeline\n\n`;
    
    postMortem.timeline.forEach(({ time, event }) => {
      markdown += `- **${time}:** ${event}\n`;
    });
    
    markdown += `\n## Root Cause\n${postMortem.rootCause.description}\n\n`;
    markdown += `### Contributing Factors\n`;
    postMortem.rootCause.contributingFactors.forEach(factor => {
      markdown += `- ${factor}\n`;
    });
    
    markdown += `\n## Impact\n`;
    markdown += `- **Users Affected:** ${postMortem.impact.usersAffected}\n`;
    markdown += `- **Downtime:** ${postMortem.impact.downtime} minutes\n`;
    if (postMortem.impact.dataLoss) {
      markdown += `- **Data Loss:** Yes\n`;
    }
    
    markdown += `\n## Action Items\n\n`;
    postMortem.actions.forEach(action => {
      markdown += `- [${action.status}] ${action.item} (${action.owner})\n`;
    });
    
    markdown += `\n## Lessons Learned\n`;
    postMortem.lessons.forEach(lesson => {
      markdown += `- ${lesson}\n`;
    });
    
    return markdown;
  }
}

export const postMortemManager = PostMortemManager.getInstance();
```

---

## Quick Reference: Troubleshooting Commands

```bash
# Production monitoring commands
npm run monitoring:check       # Check monitoring status
npm run monitoring:alerts      # List active alerts
npm run monitoring:metrics     # Show key metrics

# Crash analysis
npm run crash:analyze          # Analyze latest crashes
npm run crash:list             # List all crashes
npm run crash:report           # Generate crash report

# Performance diagnosis
npm run perf:profile           # Start performance profiling
npm run perf:report            # Generate performance report
npm run perf:analyze           # Analyze performance issues

# Incident response
npm run incident:list          # List active incidents
npm run incident:create        # Create new incident
npm run incident:update        # Update incident status
npm run incident:resolve       # Resolve incident

# Post-mortem
npm run postmortem:create      # Create post-mortem
npm run postmortem:list        # List post-mortems
npm run postmortem:export      # Export post-mortem as markdown
```

---

This appendix provides a comprehensive troubleshooting framework for production React Native applications. By implementing these monitoring, analysis, and incident response strategies, you'll be prepared to quickly identify, diagnose, and resolve issues in your production environment.
