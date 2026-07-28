# Primer 20: Edge AI and TinyML

## Overview

This primer provides a comprehensive introduction to Edge AI and TinyML—the field of running machine learning models on edge devices with limited resources. Understanding these concepts is essential for deploying ML in IoT, mobile, embedded, and real-time applications where cloud connectivity isn't always available.

---

## 1. Introduction to Edge AI

### The Edge AI Landscape

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE EDGE AI LANDSCAPE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Cloud AI                                                       │
│  └── Large models, unlimited compute, high latency             │
│      • Data centers                                            │
│      • GPU clusters                                            │
│      • Training + Inference                                    │
│                                                                 │
│  Edge AI                                                        │
│  └── Medium models, limited compute, low latency               │
│      • On-premise servers                                      │
│      • Edge gateways                                           │
│      • Inference only                                          │
│                                                                 │
│  TinyML                                                         │
│  └── Tiny models, very limited resources, ultra-low latency    │
│      • Microcontrollers                                        │
│      • IoT devices                                             │
│      • Battery-powered devices                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why Edge AI?

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHY EDGE AI?                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Benefits of Running ML on Edge Devices                        │
│                                                                 │
│  1. Low Latency                                                │
│     └── No round-trip to cloud                                │
│     └── Real-time processing                                  │
│                                                                 │
│  2. Privacy and Security                                       │
│     └── Data stays on device                                  │
│     └── No data transmission                                  │
│     └── GDPR compliance                                       │
│                                                                 │
│  3. Reliability                                                │
│     └── Works offline                                         │
│     └── No network dependency                                 │
│     └── Resilient                                             │
│                                                                 │
│  4. Cost Efficiency                                            │
│     └── No cloud costs                                        │
│     └── Lower bandwidth usage                                 │
│     └── Scalable                                              │
│                                                                 │
│  5. Power Efficiency                                           │
│     └── Optimized for edge                                    │
│     └── Battery-friendly                                      │
│     └── Sustainable                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Edge AI Hardware

### Hardware Platforms

```
┌─────────────────────────────────────────────────────────────────┐
│                    EDGE AI HARDWARE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Microcontrollers (MCUs)                                       │
│  ├── ARM Cortex-M                                              │
│  ├── ESP32                                                     │
│  ├── Raspberry Pi Pico                                        │
│  └── Arduino                                                   │
│      • RAM: KB to MB                                           │
│      • Flash: MB                                               │
│      • Power: mW                                               │
│      • Cost: $5-50                                             │
│                                                                 │
│  Embedded Processors                                           │
│  ├── Raspberry Pi                                              │
│  ├── NVIDIA Jetson                                            │
│  ├── Google Coral                                             │
│  └── Intel Movidius                                           │
│      • RAM: GB                                                 │
│      • Flash: GB                                               │
│      • Power: W                                                │
│      • Cost: $50-500                                           │
│                                                                 │
│  Mobile Processors                                             │
│  ├── Apple A-series                                            │
│  ├── Qualcomm Snapdragon                                      │
│  ├── Samsung Exynos                                           │
│  └── Google Tensor                                            │
│      • RAM: GB                                                 │
│      • Flash: GB                                               │
│      • Power: W                                                │
│      • Cost: $100-1000                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Neural Processing Units (NPUs)

```python
def check_hardware_acceleration():
    """
    Check for available hardware acceleration.
    
    Returns:
        dict: Available hardware
    """
    available = {}
    
    # Check for GPU
    try:
        import torch
        available['cuda'] = torch.cuda.is_available()
        if available['cuda']:
            available['cuda_device'] = torch.cuda.get_device_name(0)
    except:
        pass
    
    # Check for TensorFlow Lite
    try:
        import tensorflow as tf
        available['tflite'] = True
    except:
        available['tflite'] = False
    
    # Check for OpenVINO
    try:
        from openvino.runtime import Core
        available['openvino'] = True
    except:
        available['openvino'] = False
    
    # Check for Coral Edge TPU
    try:
        from pycoral.utils import edgetpu
        available['edgetpu'] = True
    except:
        available['edgetpu'] = False
    
    return available

# Example usage
hardware = check_hardware_acceleration()
print("Available Hardware:")
for hw, status in hardware.items():
    print(f"  {hw}: {status}")
```

---

## 3. Model Optimization for Edge

### Model Size Reduction

```python
def calculate_model_size(model):
    """
    Calculate model size in MB.
    
    Args:
        model: PyTorch or TensorFlow model
    
    Returns:
        float: Model size in MB
    """
    import io
    import torch
    import numpy as np
    
    if hasattr(model, 'state_dict'):
        # PyTorch model
        buffer = io.BytesIO()
        torch.save(model.state_dict(), buffer)
        size_bytes = buffer.getbuffer().nbytes
    elif hasattr(model, 'save_weights'):
        # TensorFlow model
        buffer = io.BytesIO()
        model.save_weights(buffer)
        size_bytes = len(buffer.getvalue())
    else:
        # Generic
        import pickle
        buffer = io.BytesIO()
        pickle.dump(model, buffer)
        size_bytes = buffer.getbuffer().nbytes
    
    return size_bytes / (1024 * 1024)

def model_size_report(model):
    """
    Generate model size report.
    
    Args:
        model: Model to analyze
    
    Returns:
        dict: Size report
    """
    import torch
    
    report = {
        'size_mb': calculate_model_size(model),
        'parameter_count': 0
    }
    
    if hasattr(model, 'parameters'):
        report['parameter_count'] = sum(p.numel() for p in model.parameters())
    elif hasattr(model, 'count_params'):
        report['parameter_count'] = model.count_params()
    
    return report
```

### TensorFlow Lite for Microcontrollers

```python
def convert_to_tflite(model, representative_dataset=None, int8=False):
    """
    Convert model to TensorFlow Lite format.
    
    Args:
        model: TensorFlow model
        representative_dataset: Data for quantization
        int8: Whether to use int8 quantization
    
    Returns:
        bytes: TFLite model
    """
    import tensorflow as tf
    
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimization
    if int8:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        if representative_dataset:
            converter.representative_dataset = representative_dataset
            converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
            converter.inference_input_type = tf.uint8
            converter.inference_output_type = tf.uint8
    
    # Convert
    tflite_model = converter.convert()
    
    return tflite_model

def create_micro_controller_model():
    """
    Create a model suitable for microcontrollers.
    
    Returns:
        tf.keras.Model: Tiny model
    """
    import tensorflow as tf
    
    # Tiny model for keyword spotting
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(40, 40, 1)),
        
        # Depthwise separable convolution (efficient)
        tf.keras.layers.DepthwiseConv2D(3, padding='same'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        
        tf.keras.layers.Conv2D(8, 1, padding='same'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.Dense(4, activation='softmax')
    ])
    
    return model

def save_tflite_for_micro(tflite_model, output_path):
    """
    Save TFLite model for microcontrollers.
    
    Args:
        tflite_model: TFLite model bytes
        output_path: Output file path
    """
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"TFLite model saved to: {output_path}")
    
    # Generate C++ header (for Arduino)
    cpp_path = output_path.replace('.tflite', '.cpp')
    with open(cpp_path, 'w') as f:
        f.write(f"""
#include <Arduino.h>

// TFLite model data
const unsigned char tflite_model[] = {{
""")
        
        for i, byte in enumerate(tflite_model):
            if i % 16 == 0:
                f.write("\n  ")
            f.write(f"0x{byte:02x}, ")
        
        f.write("""
};

const unsigned int tflite_model_len = sizeof(tflite_model);
""")
    
    print(f"C++ header saved to: {cpp_path}")
```

### PyTorch Mobile

```python
def convert_to_pytorch_mobile(model, sample_input, output_path):
    """
    Convert PyTorch model for mobile.
    
    Args:
        model: PyTorch model
        sample_input: Sample input for tracing
        output_path: Output file path
    """
    import torch
    
    # Trace model
    traced_model = torch.jit.trace(model, sample_input)
    
    # Optimize for mobile
    optimized_model = torch.jit.optimize_for_inference(traced_model)
    
    # Save
    optimized_model._save_for_lite_interpreter(output_path)
    
    print(f"PyTorch Mobile model saved to: {output_path}")

def quantize_for_mobile(model, sample_input, output_path):
    """
    Quantize PyTorch model for mobile.
    
    Args:
        model: PyTorch model
        sample_input: Sample input for calibration
        output_path: Output file path
    """
    import torch
    
    # Prepare for quantization
    model.eval()
    model.qconfig = torch.quantization.get_default_qconfig('fbgemm')
    
    # Fuse layers
    torch.quantization.fuse_modules(model, [['conv1', 'bn1', 'relu1']], inplace=True)
    
    # Prepare and calibrate
    model_prepared = torch.quantization.prepare(model)
    
    # Calibrate
    with torch.no_grad():
        for _ in range(10):
            model_prepared(sample_input)
    
    # Convert
    model_quantized = torch.quantization.convert(model_prepared)
    
    # Save
    model_quantized._save_for_lite_interpreter(output_path)
    
    print(f"Quantized model saved to: {output_path}")
```

---

## 4. TinyML Applications

### Keyword Spotting

```python
def build_keyword_model():
    """
    Build a keyword spotting model for TinyML.
    
    Returns:
        tf.keras.Model: Keyword model
    """
    import tensorflow as tf
    
    # Simple CNN for keyword spotting
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(40, 40, 1)),
        
        # First conv block
        tf.keras.layers.Conv2D(8, 3, padding='same'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.MaxPooling2D(2),
        
        # Second conv block
        tf.keras.layers.Conv2D(16, 3, padding='same'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.MaxPooling2D(2),
        
        # Third conv block
        tf.keras.layers.Conv2D(32, 3, padding='same'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.GlobalAveragePooling2D(),
        
        # Output
        tf.keras.layers.Dense(10, activation='softmax')
    ])
    
    return model

def keyword_inference_on_micro(model_path, audio_data):
    """
    Run keyword inference on microcontroller.
    
    Args:
        model_path: Path to TFLite model
        audio_data: Audio data (MFCC features)
    
    Returns:
        dict: Keyword predictions
    """
    import tensorflow as tf
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    
    # Get input/output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # Set input
    interpreter.set_tensor(input_details[0]['index'], audio_data)
    
    # Run inference
    interpreter.invoke()
    
    # Get output
    output = interpreter.get_tensor(output_details[0]['index'])
    
    keywords = ['yes', 'no', 'up', 'down', 'left', 'right', 'on', 'off', 'stop', 'go']
    
    return {keyword: float(output[0][i]) for i, keyword in enumerate(keywords)}
```

### Image Classification (MobileNet)

```python
def mobilenet_for_edge(input_shape=(128, 128, 3), num_classes=10):
    """
    Create MobileNet variant for edge devices.
    
    Args:
        input_shape: Input image shape
        num_classes: Number of classes
    
    Returns:
        tf.keras.Model: MobileNet model
    """
    import tensorflow as tf
    
    # Use MobileNetV2 as base
    base = tf.keras.applications.MobileNetV2(
        input_shape=input_shape,
        include_top=False,
        weights='imagenet'
    )
    
    # Freeze base
    base.trainable = False
    
    # Add custom head
    model = tf.keras.Sequential([
        base,
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    return model

def optimize_for_edgetpu(model, representative_dataset):
    """
    Optimize model for Coral Edge TPU.
    
    Args:
        model: TensorFlow model
        representative_dataset: Data for quantization
    
    Returns:
        bytes: EdgeTPU compatible model
    """
    import tensorflow as tf
    
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.TFLITE_BUILTINS_INT8
    ]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8
    
    tflite_model = converter.convert()
    
    return tflite_model
```

---

## 5. Edge AI Deployment

### IoT Device Integration

```python
# Example: ESP32 with TFLite Micro

class ESP32Inference:
    """
    Inference on ESP32 with TFLite Micro.
    """
    
    def __init__(self, model_path):
        self.model_path = model_path
        self.interpreter = None
    
    def setup(self):
        """Initialize the TFLite interpreter."""
        import tensorflow as tf
        
        self.interpreter = tf.lite.Interpreter(model_path=self.model_path)
        self.interpreter.allocate_tensors()
    
    def predict(self, input_data):
        """Run inference."""
        if self.interpreter is None:
            self.setup()
        
        # Get input/output details
        input_details = self.interpreter.get_input_details()
        output_details = self.interpreter.get_output_details()
        
        # Set input
        self.interpreter.set_tensor(input_details[0]['index'], input_data)
        
        # Run inference
        self.interpreter.invoke()
        
        # Get output
        output = self.interpreter.get_tensor(output_details[0]['index'])
        
        return output

# Example inference loop
def edge_inference_loop():
    """
    Continuous inference on edge device.
    """
    import time
    
    model = ESP32Inference('model.tflite')
    model.setup()
    
    print("Starting edge inference...")
    
    while True:
        # Get sensor data (simulated)
        sensor_data = get_sensor_data()
        
        # Run inference
        result = model.predict(sensor_data)
        
        # Process result
        process_result(result)
        
        # Wait for next cycle
        time.sleep(0.1)  # 10Hz
```

### Web Assembly (WASM)

```python
def export_to_wasm(model_path, output_path):
    """
    Export model to Web Assembly.
    
    Args:
        model_path: Path to TensorFlow model
        output_path: Output path for WASM
    """
    import tensorflow as tf
    
    # Load TFLite model
    converter = tf.lite.TFLiteConverter.from_saved_model(model_path)
    tflite_model = converter.convert()
    
    # Save for WASM
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"WASM model saved to: {output_path}")

# JavaScript inference
js_code = """
// Load TFLite model
const model = await tflite.loadTFLiteModel('model.tflite');

// Run inference
const input = new Float32Array([...]);
const output = model.predict(input);
console.log('Prediction:', output);
"""
```

---

## Quick Reference: Edge AI and TinyML

### Edge AI Framework Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  FRAMEWORK    │ PLATFORMS      │ SIZE   │ SPEED  │ EASE       │
├───────────────┼────────────────┼────────┼────────┼────────────┤
│  TFLite Micro │ MCUs           │ Tiny   │ Good   │ Good       │
│  TensorFlow   │ Mobile, Web    │ Small  │ Good   │ Excellent  │
│  PyTorch      │ Mobile, Edge   │ Medium │ Good   │ Excellent  │
│  OpenVINO     │ Intel Edge     │ Medium │ Fast   │ Good       │
│  Coral        │ Edge TPU       │ Medium │ Very   │ Good       │
│  TinyML       │ MCUs           │ Tiny   │ Good   │ Medium     │
└─────────────────────────────────────────────────────────────────┘
```

### Edge AI Hardware

```
┌─────────────────────────────────────────────────────────────────┐
│  DEVICE       │ RAM    │ FLASH  │ POWER   │ USE CASE         │
├───────────────┼────────┼────────┼─────────┼──────────────────┤
│  ESP32        │ 520KB  │ 4MB    │ 100mW   │ IoT, Sensors     │
│  Raspberry Pi │ 1-8GB  │ 8-64GB │ 3-5W    │ Gateway, Vision  │
│  Jetson Nano  │ 4GB    │ 16GB   │ 5-10W   │ Vision, Robotics │
│  Coral Dev    │ 1GB    │ 8GB    │ 2W      │ Edge AI          │
│  Arduino      │ 2KB    │ 32KB   │ 10mW    │ Simple sensing   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of Edge AI and TinyML. You now understand:

1. **Edge AI landscape**: Cloud vs Edge vs TinyML
2. **Hardware platforms**: MCUs, embedded, mobile
3. **Model optimization**: Size reduction, quantization
4. **TinyML frameworks**: TFLite Micro, PyTorch Mobile
5. **Applications**: Keyword spotting, image classification
6. **Deployment**: IoT integration, WASM

**Next Steps:**
1. Try TFLite Micro on a microcontroller
2. Optimize a model for edge deployment
3. Deploy a model on Raspberry Pi
4. Build a TinyML application
5. Proceed to Part 1 of the series

---

*End of Primer 20*
