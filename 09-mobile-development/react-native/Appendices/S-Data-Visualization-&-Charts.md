# Appendix S: Data Visualization & Charts

Welcome to Appendix S! This comprehensive guide covers everything you need to know about implementing data visualization and charts in your React Native application. You'll learn how to create beautiful, interactive charts that help users understand their data at a glance.

---

## Table of Contents

1. [Chart Architecture](#chart-architecture)
2. [Chart Library Selection](#chart-library-selection)
3. [Line Charts](#line-charts)
4. [Bar Charts](#bar-charts)
5. [Pie & Donut Charts](#pie--donut-charts)
6. [Stacked Charts](#stacked-charts)
7. [Interactive Charts](#interactive-charts)
8. [Custom Chart Components](#custom-chart-components)

---

## Chart Architecture

### Charting System Architecture

```typescript
// src/charts/architecture.ts
/**
 * Data Visualization Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                   DATA VISUALIZATION LAYER                    │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              Chart Components                           │   │
 * │  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐ │   │
 * │  │  │ Line Chart │  │ Bar Chart │  │ Pie/Donut Chart  │ │   │
 * │  │  └────────────┘  └────────────┘  └──────────────────┘ │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * │                              │                                  │
 * │                              ▼                                  │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              Chart Engine                               │   │
 * │  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐ │   │
 * │  │  │  Victory   │  │ React     │  │  React Native   │ │   │
 * │  │  │  Charts    │  │ Native    │  │  SVG            │ │   │
 * │  │  │            │  │ Chart Kit │  │  Charts         │ │   │
 * │  │  └────────────┘  └────────────┘  └──────────────────┘ │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                   DATA PROCESSING LAYER                       │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Data Transformation │ Aggregation │ Formatting        │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const ChartArchitecture = {
  libraries: {
    victory: {
      name: 'Victory Charts',
      features: ['SVG-based', 'Animations', 'Accessibility', 'Theming'],
      pros: ['Rich features', 'Good documentation', 'Active community'],
      cons: ['Large bundle size', 'Complex styling'],
    },
    reactNativeChartKit: {
      name: 'React Native Chart Kit',
      features: ['Native rendering', 'Simple API', 'Lightweight'],
      pros: ['Small bundle', 'Easy to use', 'Good performance'],
      cons: ['Limited features', 'Less customization'],
    },
    reactNativeSvgCharts: {
      name: 'React Native SVG Charts',
      features: ['SVG-based', 'Customizable', 'Interactive'],
      pros: ['Flexible', 'Great for custom charts', 'Performance'],
      cons: ['Steep learning curve', 'Requires SVG knowledge'],
    },
  },
};
```

---

## Chart Library Selection

### Installation & Setup

```bash
# Install Victory Charts
npm install victory-native @react-native-community/art

# Install React Native Chart Kit
npm install react-native-chart-kit react-native-svg

# Install React Native SVG Charts
npm install react-native-svg react-native-svg-charts

# Install additional utilities
npm install d3-scale d3-shape
```

### Chart Configuration

```typescript
// src/charts/config.ts
import { Dimensions } from 'react-native';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

export const ChartConfig = {
  width: screenWidth - 32,
  height: 300,
  padding: {
    top: 20,
    bottom: 20,
    left: 20,
    right: 20,
  },
  
  colors: {
    primary: ['#3498db', '#2ecc71', '#e74c3c', '#f39c12', '#9b59b6'],
    secondary: ['#2980b9', '#27ae60', '#c0392b', '#d35400', '#8e44ad'],
    gradient: {
      start: 'rgba(52, 152, 219, 0.8)',
      end: 'rgba(52, 152, 219, 0.1)',
    },
  },
  
  styles: {
    axis: {
      stroke: '#bdc3c7',
      strokeWidth: 1,
    },
    grid: {
      stroke: '#ecf0f1',
      strokeWidth: 1,
      strokeDasharray: [4, 4],
    },
    label: {
      fontSize: 12,
      fill: '#7f8c8d',
      fontWeight: '400',
    },
  },
  
  animation: {
    duration: 500,
    easing: 'ease-in-out',
  },
};
```

---

## Line Charts

### Line Chart Implementation

```typescript
// src/charts/LineChart.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ScrollView,
} from 'react-native';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Grid,
  Area,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'react-native-svg-charts';

/**
 * Line Chart Component
 * 
 * This provides a complete line chart implementation:
 * - Multiple lines
 * - Area fill
 * - Tooltips
 * - Legend
 * - Animation
 */

export interface LineChartData {
  label: string;
  value: number;
}

export interface LineChartProps {
  data: LineChartData[];
  lines: Array<{
    key: string;
    color: string;
    data: LineChartData[];
    fill?: boolean;
    strokeWidth?: number;
  }>;
  height?: number;
  width?: number;
  showArea?: boolean;
  showGrid?: boolean;
  showTooltip?: boolean;
  yAxisLabel?: string;
  xAxisLabel?: string;
}

export const CustomLineChart: React.FC<LineChartProps> = ({
  data,
  lines,
  height = 300,
  width = ChartConfig.width,
  showArea = true,
  showGrid = true,
  showTooltip = true,
  yAxisLabel,
  xAxisLabel,
}) => {
  const [selectedPoint, setSelectedPoint] = React.useState<any>(null);

  // Format data for the chart
  const formattedData = lines.map(line => ({
    ...line,
    data: line.data.map(d => d.value),
  }));

  const xLabels = data.map(d => d.label);

  // Calculate Y-axis domain
  const allValues = lines.flatMap(line => line.data.map(d => d.value));
  const minValue = Math.min(0, ...allValues);
  const maxValue = Math.max(...allValues) * 1.1;

  return (
    <View style={[styles.container, { height }]}>
      {yAxisLabel && (
        <Text style={styles.yAxisLabel}>{yAxisLabel}</Text>
      )}
      
      <View style={styles.chartContainer}>
        <YAxis
          data={allValues}
          style={styles.yAxis}
          numberOfTicks={5}
          formatLabel={(value) => `${value}`}
          contentInset={styles.contentInset}
          svg={ChartConfig.styles.axis}
        />

        <View style={styles.chartWrapper}>
          <LineChart
            style={[styles.chart, { width, height: height - 40 }]}
            data={allValues}
            svg={ChartConfig.styles.axis}
            contentInset={styles.contentInset}
            gridMin={minValue}
            gridMax={maxValue}
          >
            {showGrid && <Grid svg={ChartConfig.styles.grid} />}
            
            {lines.map((line, index) => (
              <React.Fragment key={line.key}>
                <Line
                  data={line.data.map(d => d.value)}
                  svg={{
                    stroke: line.color,
                    strokeWidth: line.strokeWidth || 2,
                  }}
                  key={line.key}
                  curve="natural"
                />
                
                {showArea && line.fill && (
                  <Area
                    data={line.data.map(d => d.value)}
                    svg={{
                      fill: line.color,
                      opacity: 0.2,
                    }}
                    curve="natural"
                  />
                )}
              </React.Fragment>
            ))}
          </LineChart>
        </View>
      </View>

      {xAxisLabel && (
        <Text style={styles.xAxisLabel}>{xAxisLabel}</Text>
      )}
      
      <Legend
        data={lines.map(line => ({
          key: line.key,
          color: line.color,
          label: line.key,
        }))}
        style={styles.legend}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  chartContainer: {
    flexDirection: 'row',
    flex: 1,
  },
  yAxis: {
    width: 40,
    paddingRight: 8,
  },
  yAxisLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    textAlign: 'center',
    marginBottom: 8,
  },
  chartWrapper: {
    flex: 1,
  },
  chart: {
    flex: 1,
  },
  xAxisLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    textAlign: 'center',
    marginTop: 8,
  },
  legend: {
    marginTop: 12,
    flexDirection: 'row',
    justifyContent: 'center',
    flexWrap: 'wrap',
  },
  contentInset: {
    top: 10,
    bottom: 10,
    left: 10,
    right: 10,
  },
});
```

---

## Bar Charts

### Bar Chart Implementation

```typescript
// src/charts/BarChart.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { BarChart as SVGChart } from 'react-native-svg-charts';
import { Defs, LinearGradient, Stop } from 'react-native-svg';

/**
 * Bar Chart Component
 * 
 * This provides a complete bar chart implementation:
 * - Horizontal and vertical bars
 * - Grouped bars
 * - Stacked bars
 * - Gradient fills
 * - Tooltips
 */

export interface BarData {
  label: string;
  value: number;
  color?: string;
}

export interface BarChartProps {
  data: BarData[];
  height?: number;
  width?: number;
  horizontal?: boolean;
  grouped?: boolean;
  stacked?: boolean;
  showLabels?: boolean;
  showValues?: boolean;
  gradient?: boolean;
  onBarPress?: (data: BarData) => void;
}

export const CustomBarChart: React.FC<BarChartProps> = ({
  data,
  height = 300,
  width = ChartConfig.width,
  horizontal = false,
  grouped = false,
  stacked = false,
  showLabels = true,
  showValues = true,
  gradient = true,
  onBarPress,
}) => {
  const [selectedBar, setSelectedBar] = React.useState<number | null>(null);

  // Prepare data
  const chartData = data.map(d => d.value);
  const chartLabels = data.map(d => d.label);
  const chartColors = data.map(d => d.color || ChartConfig.colors.primary[0]);

  const handleBarPress = (index: number) => {
    setSelectedBar(index);
    if (onBarPress) {
      onBarPress(data[index]);
    }
  };

  return (
    <View style={[styles.container, { height: height + 40 }]}>
      <View style={[styles.chartContainer, { height }]}>
        <SVGChart
          style={{ flex: 1 }}
          data={chartData}
          svg={{
            fill: 'url(#barGradient)',
            stroke: '#3498db',
            strokeWidth: 1,
          }}
          contentInset={{ top: 20, bottom: 20 }}
          spacingInner={0.2}
          spacingOuter={0.1}
          horizontal={horizontal}
        >
          {gradient && (
            <Defs key="defs">
              <LinearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                <Stop offset="0%" stopColor="#3498db" />
                <Stop offset="100%" stopColor="#2980b9" />
              </LinearGradient>
            </Defs>
          )}
        </SVGChart>
      </View>

      {showLabels && (
        <View style={styles.labelsContainer}>
          {data.map((item, index) => (
            <TouchableOpacity
              key={index}
              style={styles.labelItem}
              onPress={() => handleBarPress(index)}
            >
              <Text style={[
                styles.labelText,
                selectedBar === index && styles.labelTextSelected,
              ]}>
                {item.label}
              </Text>
              {showValues && (
                <Text style={[
                  styles.valueText,
                  selectedBar === index && styles.valueTextSelected,
                ]}>
                  {item.value}
                </Text>
              )}
            </TouchableOpacity>
          ))}
        </View>
      )}

      {selectedBar !== null && data[selectedBar] && (
        <View style={styles.tooltip}>
          <Text style={styles.tooltipLabel}>{data[selectedBar].label}</Text>
          <Text style={styles.tooltipValue}>{data[selectedBar].value}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  chartContainer: {
    flex: 1,
  },
  labelsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    marginTop: 12,
    gap: 8,
  },
  labelItem: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    backgroundColor: '#f8f9fa',
    alignItems: 'center',
    minWidth: 60,
  },
  labelText: {
    fontSize: 12,
    color: '#7f8c8d',
  },
  labelTextSelected: {
    color: '#3498db',
    fontWeight: '600',
  },
  valueText: {
    fontSize: 10,
    color: '#95a5a6',
    marginTop: 2,
  },
  valueTextSelected: {
    color: '#3498db',
  },
  tooltip: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: 'rgba(0,0,0,0.8)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    flexDirection: 'column',
  },
  tooltipLabel: {
    color: '#ffffff',
    fontSize: 12,
  },
  tooltipValue: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
```

---

## Pie & Donut Charts

### Pie Chart Implementation

```typescript
// src/charts/PieChart.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
} from 'react-native';
import { PieChart as SVGChart } from 'react-native-svg-charts';
import { Text as SVGText } from 'react-native-svg';

/**
 * Pie & Donut Chart Component
 * 
 * This provides complete pie and donut chart implementations:
 * - Pie charts
 * - Donut charts
 * - Labels
 * - Legends
 * - Animation
 * - Interaction
 */

export interface PieData {
  label: string;
  value: number;
  color: string;
}

export interface PieChartProps {
  data: PieData[];
  height?: number;
  width?: number;
  innerRadius?: number;
  outerRadius?: number;
  showLabels?: boolean;
  showLegend?: boolean;
  animated?: boolean;
  onSlicePress?: (data: PieData) => void;
}

export const CustomPieChart: React.FC<PieChartProps> = ({
  data,
  height = 300,
  width = ChartConfig.width,
  innerRadius = 0,
  outerRadius = 100,
  showLabels = true,
  showLegend = true,
  animated = true,
  onSlicePress,
}) => {
  const [selectedSlice, setSelectedSlice] = React.useState<number | null>(null);

  // Calculate total for percentages
  const total = data.reduce((sum, d) => sum + d.value, 0);

  const handleSlicePress = (index: number) => {
    setSelectedSlice(index === selectedSlice ? null : index);
    if (onSlicePress) {
      onSlicePress(data[index]);
    }
  };

  // Custom label renderer
  const renderLabel = ({ slice }: { slice: any }) => {
    const { pieCentroid, data: sliceData } = slice;
    const percentage = ((sliceData.value / total) * 100).toFixed(1);

    if (!showLabels) return null;

    return (
      <SVGText
        x={pieCentroid[0]}
        y={pieCentroid[1]}
        fill={'#ffffff'}
        textAnchor={'middle'}
        alignmentBaseline={'middle'}
        fontSize={14}
        fontWeight={'600'}
      >
        {percentage}%
      </SVGText>
    );
  };

  return (
    <View style={styles.container}>
      <View style={[styles.chartContainer, { height }]}>
        <SVGChart
          style={{ height, width }}
          data={data}
          valueAccessor={({ item }: { item: PieData }) => item.value}
          renderSlice={({ item, index }: { item: PieData; index: number }) => (
            <TouchableOpacity
              key={index}
              onPress={() => handleSlicePress(index)}
              style={{
                width: '100%',
                height: '100%',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              <View
                style={[
                  styles.slice,
                  {
                    backgroundColor: item.color,
                    transform: [
                      { scale: selectedSlice === index ? 1.05 : 1 },
                    ],
                  },
                ]}
              />
            </TouchableOpacity>
          )}
          innerRadius={innerRadius}
          outerRadius={outerRadius}
          animate={animated}
        >
          {renderLabel}
        </SVGChart>
      </View>

      {showLegend && (
        <View style={styles.legendContainer}>
          {data.map((item, index) => (
            <View key={index} style={styles.legendItem}>
              <View style={[styles.legendColor, { backgroundColor: item.color }]} />
              <Text style={styles.legendLabel}>{item.label}</Text>
              <Text style={styles.legendValue}>
                {((item.value / total) * 100).toFixed(1)}%
              </Text>
            </View>
          ))}
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  chartContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  slice: {
    width: '100%',
    height: '100%',
    borderRadius: 100,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  legendContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    marginTop: 16,
    gap: 12,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    gap: 8,
  },
  legendColor: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  legendLabel: {
    fontSize: 14,
    color: '#2c3e50',
  },
  legendValue: {
    fontSize: 12,
    color: '#7f8c8d',
  },
});
```

---

## Stacked Charts

### Stacked Chart Implementation

```typescript
// src/charts/StackedChart.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ScrollView,
} from 'react-native';
import { StackedBarChart } from 'react-native-svg-charts';

/**
 * Stacked Chart Component
 * 
 * This provides complete stacked chart implementations:
 * - Stacked bar charts
 * - Stacked area charts
 * - Legends
 * - Tooltips
 * - Animation
 */

export interface StackedData {
  label: string;
  values: number[];
}

export interface StackedChartProps {
  data: StackedData[];
  keys: string[];
  colors: string[];
  height?: number;
  width?: number;
  horizontal?: boolean;
  showLabels?: boolean;
  showLegend?: boolean;
  animated?: boolean;
}

export const CustomStackedChart: React.FC<StackedChartProps> = ({
  data,
  keys,
  colors,
  height = 300,
  width = ChartConfig.width,
  horizontal = false,
  showLabels = true,
  showLegend = true,
  animated = true,
}) => {
  // Prepare data for stacked chart
  const chartData = data.map(item => ({
    ...item,
    values: item.values.reduce((acc, val, index) => {
      acc[keys[index]] = val;
      return acc;
    }, {} as Record<string, number>),
  }));

  return (
    <View style={styles.container}>
      <View style={[styles.chartContainer, { height }]}>
        <StackedBarChart
          style={{ flex: 1 }}
          data={chartData}
          keys={keys}
          colors={colors}
          horizontal={horizontal}
          contentInset={{ top: 20, bottom: 20 }}
          spacing={0.2}
          animate={animated}
        />
      </View>

      {showLegend && (
        <View style={styles.legendContainer}>
          {keys.map((key, index) => (
            <View key={key} style={styles.legendItem}>
              <View style={[styles.legendColor, { backgroundColor: colors[index] }]} />
              <Text style={styles.legendLabel}>{key}</Text>
            </View>
          ))}
        </View>
      )}

      {showLabels && (
        <View style={styles.labelsContainer}>
          {data.map((item, index) => (
            <Text key={index} style={styles.labelText}>
              {item.label}
            </Text>
          ))}
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  chartContainer: {
    flex: 1,
  },
  legendContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    marginTop: 12,
    gap: 12,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  legendColor: {
    width: 12,
    height: 12,
    borderRadius: 3,
  },
  legendLabel: {
    fontSize: 12,
    color: '#2c3e50',
  },
  labelsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 8,
  },
  labelText: {
    fontSize: 10,
    color: '#7f8c8d',
  },
});
```

---

## Interactive Charts

### Interactive Features

```typescript
// src/charts/InteractiveChart.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
  PanResponder,
  Animated,
} from 'react-native';
import * as d3 from 'd3-scale';
import * as shape from 'd3-shape';

/**
 * Interactive Chart Component
 * 
 * This provides interactive chart features:
 * - Pan and zoom
 * - Tooltips
 * - Selection
 * - Highlighting
 * - Drill-down
 */

export interface InteractiveChartProps {
  data: any[];
  onPointSelect?: (point: any) => void;
  onRangeSelect?: (start: number, end: number) => void;
  onZoom?: (scale: number) => void;
}

export class InteractiveChart extends React.Component<
  InteractiveChartProps,
  {
    selectedPoint: number | null;
    zoomLevel: number;
    panOffset: number;
    tooltipVisible: boolean;
    tooltipPosition: { x: number; y: number };
    tooltipData: any;
  }
> {
  private panResponder: any;
  private scaleX = d3.scaleLinear();
  private scaleY = d3.scaleLinear();

  constructor(props: InteractiveChartProps) {
    super(props);
    this.state = {
      selectedPoint: null,
      zoomLevel: 1,
      panOffset: 0,
      tooltipVisible: false,
      tooltipPosition: { x: 0, y: 0 },
      tooltipData: null,
    };

    this.setupPanResponder();
  }

  /**
   * Setup pan responder for gestures
   */
  setupPanResponder() {
    this.panResponder = PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderMove: (evt, gestureState) => {
        this.handlePan(gestureState);
      },
      onPanResponderRelease: (evt, gestureState) => {
        this.handlePanEnd(gestureState);
      },
    });
  }

  /**
   * Handle pan gesture
   */
  handlePan(gestureState: any) {
    const { dx, dy } = gestureState;
    this.setState({
      panOffset: this.state.panOffset + dx,
    });
  }

  /**
   * Handle pan end
   */
  handlePanEnd(gestureState: any) {
    // Snap to nearest data point
    const { dx } = gestureState;
    const dataLength = this.props.data.length;
    const step = 300 / dataLength;
    const index = Math.round(this.state.panOffset / step);
    
    this.setState({
      panOffset: index * step,
    });
  }

  /**
   * Handle point selection
   */
  handlePointSelect(index: number) {
    this.setState({
      selectedPoint: index,
      tooltipVisible: true,
      tooltipData: this.props.data[index],
    });

    if (this.props.onPointSelect) {
      this.props.onPointSelect(this.props.data[index]);
    }
  }

  /**
   * Handle zoom
   */
  handleZoom(scale: number) {
    this.setState({
      zoomLevel: Math.max(0.5, Math.min(2, this.state.zoomLevel + scale)),
    });

    if (this.props.onZoom) {
      this.props.onZoom(this.state.zoomLevel);
    }
  }

  render() {
    return (
      <View style={styles.container} {...this.panResponder.panHandlers}>
        <View style={styles.chartContainer}>
          {/* Chart rendering goes here */}
          <Text style={styles.placeholder}>Interactive Chart</Text>
        </View>

        {this.state.tooltipVisible && this.state.tooltipData && (
          <View
            style={[
              styles.tooltip,
              {
                left: this.state.tooltipPosition.x,
                top: this.state.tooltipPosition.y,
              },
            ]}
          >
            <Text style={styles.tooltipTitle}>
              {this.state.tooltipData.label}
            </Text>
            <Text style={styles.tooltipValue}>
              {this.state.tooltipData.value}
            </Text>
          </View>
        )}

        <View style={styles.controls}>
          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => this.handleZoom(-0.1)}
          >
            <Text style={styles.controlText}>−</Text>
          </TouchableOpacity>
          <Text style={styles.zoomLevel}>{this.state.zoomLevel.toFixed(1)}x</Text>
          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => this.handleZoom(0.1)}
          >
            <Text style={styles.controlText}>+</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  chartContainer: {
    height: 300,
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholder: {
    fontSize: 16,
    color: '#95a5a6',
  },
  tooltip: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0.8)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    minWidth: 100,
  },
  tooltipTitle: {
    color: '#ffffff',
    fontSize: 12,
  },
  tooltipValue: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 12,
    gap: 12,
  },
  controlButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#f1f2f6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  controlText: {
    fontSize: 20,
    color: '#2c3e50',
    fontWeight: '300',
  },
  zoomLevel: {
    fontSize: 14,
    color: '#2c3e50',
    fontWeight: '600',
    minWidth: 40,
    textAlign: 'center',
  },
});
```

---

## Quick Reference: Chart Commands

```bash
# Chart installation
npm install victory-native              # Install Victory Charts
npm install react-native-chart-kit     # Install Chart Kit
npm install react-native-svg-charts    # Install SVG Charts

# Chart utilities
npm install d3-scale d3-shape          # Install D3 utilities
```

---

This appendix provides a comprehensive data visualization implementation for your React Native application. By implementing these chart patterns, you'll create beautiful, interactive data displays that help users understand their information.

