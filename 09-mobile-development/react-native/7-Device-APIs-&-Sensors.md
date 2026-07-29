# Part 3: Device Capabilities & Native Interfacing
## Phase 1: Device APIs & Sensors

Welcome to Part 3! Your TaskFlow app now has a solid foundation with navigation, state management, and data persistence. In this phase, we'll make your app truly mobile by accessing device hardware—cameras, geolocation, push notifications, and more. These are the features that make mobile apps powerful and engaging.

---

## Target 1: Camera & Photo Library Integration

**The Target:** Implement camera and photo library access for task attachments.

**The Concept:** Think of the camera as your app's eyes. Users can take photos or select from their library to attach visual context to tasks. We'll implement this with proper permissions, error handling, and image optimization.

### Installation

```bash
# Install camera and image picker
npx expo install expo-camera expo-image-picker
npx expo install expo-permissions
npx expo install expo-file-system

# For image manipulation
npx expo install expo-image-manipulator
```

### Camera Service

```typescript
// src/services/cameraService.ts
import { Camera, CameraType } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import * as FileSystem from 'expo-file-system';
import * as ImageManipulator from 'expo-image-manipulator';
import { Platform, Alert } from 'react-native';

export interface ImageResult {
  uri: string;
  width: number;
  height: number;
  base64?: string;
  fileName?: string;
  fileSize?: number;
}

export interface CameraOptions {
  allowsEditing?: boolean;
  aspect?: [number, number];
  quality?: number;
  base64?: boolean;
  maxWidth?: number;
  maxHeight?: number;
}

/**
 * CameraService - Handles camera and photo library operations
 * 
 * This service manages image capture, selection, and optimization
 * with proper permission handling and error management.
 */
export class CameraService {
  private static instance: CameraService;

  private constructor() {}

  static getInstance(): CameraService {
    if (!CameraService.instance) {
      CameraService.instance = new CameraService();
    }
    return CameraService.instance;
  }

  /**
   * Request camera permissions
   */
  async requestCameraPermissions(): Promise<boolean> {
    try {
      const { status } = await Camera.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Camera access is needed to take photos for your tasks.',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Settings', onPress: () => this.openSettings() },
          ]
        );
        return false;
      }
      return true;
    } catch (error) {
      console.error('Error requesting camera permissions:', error);
      return false;
    }
  }

  /**
   * Request photo library permissions
   */
  async requestMediaLibraryPermissions(): Promise<boolean> {
    try {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Photo library access is needed to select images for your tasks.',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Settings', onPress: () => this.openSettings() },
          ]
        );
        return false;
      }
      return true;
    } catch (error) {
      console.error('Error requesting media library permissions:', error);
      return false;
    }
  }

  /**
   * Open app settings (platform-specific)
   */
  private openSettings() {
    if (Platform.OS === 'ios') {
      // @ts-ignore - Linking.openURL with app-settings
      Linking.openURL('app-settings:');
    } else {
      // @ts-ignore - Android intent
      IntentLauncher.startActivityAsync(
        IntentLauncher.ActivityAction.APPLICATION_DETAILS_SETTINGS,
        { data: 'package:com.yourcompany.taskflow' }
      );
    }
  }

  /**
   * Take a photo with the camera
   */
  async takePhoto(options: CameraOptions = {}): Promise<ImageResult | null> {
    const hasPermission = await this.requestCameraPermissions();
    if (!hasPermission) return null;

    try {
      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: options.allowsEditing ?? true,
        aspect: options.aspect ?? [4, 3],
        quality: options.quality ?? 0.8,
        base64: options.base64 ?? false,
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
      });

      if (!result.canceled && result.assets.length > 0) {
        const asset = result.assets[0];
        return await this.optimizeImage(asset, options);
      }

      return null;
    } catch (error) {
      console.error('Error taking photo:', error);
      Alert.alert('Error', 'Failed to take photo. Please try again.');
      return null;
    }
  }

  /**
   * Pick an image from the photo library
   */
  async pickImage(options: CameraOptions = {}): Promise<ImageResult | null> {
    const hasPermission = await this.requestMediaLibraryPermissions();
    if (!hasPermission) return null;

    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        allowsEditing: options.allowsEditing ?? true,
        aspect: options.aspect ?? [4, 3],
        quality: options.quality ?? 0.8,
        base64: options.base64 ?? false,
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
      });

      if (!result.canceled && result.assets.length > 0) {
        const asset = result.assets[0];
        return await this.optimizeImage(asset, options);
      }

      return null;
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert('Error', 'Failed to select image. Please try again.');
      return null;
    }
  }

  /**
   * Optimize image (resize, compress)
   */
  private async optimizeImage(
    asset: ImagePicker.ImagePickerAsset,
    options: CameraOptions
  ): Promise<ImageResult> {
    try {
      let image = asset;

      // Resize if max dimensions specified
      if (options.maxWidth || options.maxHeight) {
        const manipResult = await ImageManipulator.manipulateAsync(
          asset.uri,
          [
            {
              resize: {
                width: options.maxWidth || asset.width,
                height: options.maxHeight || asset.height,
              },
            },
          ],
          {
            compress: options.quality ?? 0.8,
            format: ImageManipulator.SaveFormat.JPEG,
            base64: options.base64 ?? false,
          }
        );

        image = {
          ...asset,
          uri: manipResult.uri,
          width: manipResult.width,
          height: manipResult.height,
        };
      }

      // Get file info
      const fileInfo = await FileSystem.getInfoAsync(image.uri);

      return {
        uri: image.uri,
        width: image.width,
        height: image.height,
        base64: image.base64,
        fileName: image.fileName || `image_${Date.now()}.jpg`,
        fileSize: fileInfo.size,
      };
    } catch (error) {
      console.error('Error optimizing image:', error);
      // Return original image if optimization fails
      return {
        uri: asset.uri,
        width: asset.width,
        height: asset.height,
        base64: asset.base64,
        fileName: asset.fileName || `image_${Date.now()}.jpg`,
      };
    }
  }

  /**
   * Save image to app's local storage
   */
  async saveImageToLocalStorage(
    imageUri: string,
    fileName?: string
  ): Promise<string> {
    try {
      const directory = `${FileSystem.documentDirectory}images/`;
      const dirInfo = await FileSystem.getInfoAsync(directory);
      
      if (!dirInfo.exists) {
        await FileSystem.makeDirectoryAsync(directory, { intermediates: true });
      }

      const extension = imageUri.split('.').pop() || 'jpg';
      const name = fileName || `task_image_${Date.now()}.${extension}`;
      const path = `${directory}${name}`;

      await FileSystem.copyAsync({
        from: imageUri,
        to: path,
      });

      return path;
    } catch (error) {
      console.error('Error saving image:', error);
      throw new Error('Failed to save image');
    }
  }

  /**
   * Delete image from local storage
   */
  async deleteImageFromLocalStorage(imagePath: string): Promise<void> {
    try {
      const fileInfo = await FileSystem.getInfoAsync(imagePath);
      if (fileInfo.exists) {
        await FileSystem.deleteAsync(imagePath);
      }
    } catch (error) {
      console.error('Error deleting image:', error);
    }
  }

  /**
   * Get image as base64
   */
  async getImageAsBase64(uri: string): Promise<string | null> {
    try {
      const base64 = await FileSystem.readAsStringAsync(uri, {
        encoding: FileSystem.EncodingType.Base64,
      });
      return base64;
    } catch (error) {
      console.error('Error reading image as base64:', error);
      return null;
    }
  }
}

export const cameraService = CameraService.getInstance();
```

### Image Attachment Component

```typescript
// src/components/ImageAttachment.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Platform,
  Alert,
} from 'react-native';
import * as ImageManipulator from 'expo-image-manipulator';
import { cameraService, ImageResult } from '../services/cameraService';

interface ImageAttachmentProps {
  onImageSelected?: (image: ImageResult) => void;
  onImageRemoved?: () => void;
  maxImages?: number;
  initialImages?: ImageResult[];
  readonly?: boolean;
}

export const ImageAttachment: React.FC<ImageAttachmentProps> = ({
  onImageSelected,
  onImageRemoved,
  maxImages = 5,
  initialImages = [],
  readonly = false,
}) => {
  const [images, setImages] = useState<ImageResult[]>(initialImages);
  const [uploading, setUploading] = useState(false);

  const handleAddImage = async () => {
    if (images.length >= maxImages) {
      Alert.alert('Limit Reached', `You can add up to ${maxImages} images`);
      return;
    }

    // Show options: Take Photo or Choose from Library
    Alert.alert(
      'Add Image',
      'Choose an option',
      [
        {
          text: 'Take Photo',
          onPress: handleTakePhoto,
        },
        {
          text: 'Choose from Library',
          onPress: handlePickImage,
        },
        {
          text: 'Cancel',
          style: 'cancel',
        },
      ],
      { cancelable: true }
    );
  };

  const handleTakePhoto = async () => {
    setUploading(true);
    try {
      const image = await cameraService.takePhoto({
        quality: 0.8,
        maxWidth: 1200,
        maxHeight: 1200,
        base64: false,
      });

      if (image) {
        const savedPath = await cameraService.saveImageToLocalStorage(image.uri);
        const newImage = { ...image, uri: savedPath };
        setImages(prev => [...prev, newImage]);
        onImageSelected?.(newImage);
      }
    } catch (error) {
      console.error('Error taking photo:', error);
      Alert.alert('Error', 'Failed to take photo');
    } finally {
      setUploading(false);
    }
  };

  const handlePickImage = async () => {
    setUploading(true);
    try {
      const image = await cameraService.pickImage({
        quality: 0.8,
        maxWidth: 1200,
        maxHeight: 1200,
        base64: false,
      });

      if (image) {
        const savedPath = await cameraService.saveImageToLocalStorage(image.uri);
        const newImage = { ...image, uri: savedPath };
        setImages(prev => [...prev, newImage]);
        onImageSelected?.(newImage);
      }
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert('Error', 'Failed to pick image');
    } finally {
      setUploading(false);
    }
  };

  const handleRemoveImage = async (index: number) => {
    const imageToRemove = images[index];
    if (imageToRemove) {
      await cameraService.deleteImageFromLocalStorage(imageToRemove.uri);
    }
    
    setImages(prev => prev.filter((_, i) => i !== index));
    if (images.length === 1) {
      onImageRemoved?.();
    }
  };

  const renderImageItem = (image: ImageResult, index: number) => (
    <View key={index} style={styles.imageContainer}>
      <Image source={{ uri: image.uri }} style={styles.imageThumb} />
      
      {!readonly && (
        <TouchableOpacity
          style={styles.removeButton}
          onPress={() => handleRemoveImage(index)}
        >
          <Text style={styles.removeText}>✕</Text>
        </TouchableOpacity>
      )}
      
      {image.fileName && (
        <Text style={styles.imageName} numberOfLines={1}>
          {image.fileName}
        </Text>
      )}
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.label}>
        Attachments ({images.length}/{maxImages})
      </Text>

      {uploading && (
        <View style={styles.uploadingContainer}>
          <ActivityIndicator size="large" color="#3498db" />
          <Text style={styles.uploadingText}>Processing image...</Text>
        </View>
      )}

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.imagesScrollContent}
      >
        {images.map(renderImageItem)}

        {!readonly && images.length < maxImages && (
          <TouchableOpacity style={styles.addButton} onPress={handleAddImage}>
            <Text style={styles.addButtonText}>+</Text>
            <Text style={styles.addButtonLabel}>Add Image</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 12,
  },
  imagesScrollContent: {
    paddingVertical: 4,
  },
  imageContainer: {
    marginRight: 12,
    alignItems: 'center',
    position: 'relative',
  },
  imageThumb: {
    width: 100,
    height: 100,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  removeButton: {
    position: 'absolute',
    top: -8,
    right: -8,
    backgroundColor: '#e74c3c',
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#ffffff',
  },
  removeText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  imageName: {
    fontSize: 10,
    color: '#7f8c8d',
    marginTop: 4,
    maxWidth: 100,
  },
  addButton: {
    width: 100,
    height: 100,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#e1e8ed',
    borderStyle: 'dashed',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f8f9fa',
  },
  addButtonText: {
    fontSize: 32,
    color: '#3498db',
    fontWeight: '300',
  },
  addButtonLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 4,
  },
  uploadingContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  uploadingText: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 8,
  },
});
```

---

## Target 2: Geolocation Services

**The Target:** Implement location services for task location tagging.

**The Concept:** Geolocation allows your app to know where the user is. This is useful for location-based tasks, check-in features, and contextual reminders.

### Installation

```bash
npx expo install expo-location
```

### Location Service

```typescript
// src/services/locationService.ts
import * as Location from 'expo-location';
import { Alert, Platform } from 'react-native';

export interface LocationData {
  latitude: number;
  longitude: number;
  altitude?: number;
  accuracy?: number;
  timestamp: number;
  address?: string;
}

export interface GeocodeResult {
  street?: string;
  city?: string;
  region?: string;
  country?: string;
  postalCode?: string;
  name?: string;
}

/**
 * LocationService - Handles device location operations
 * 
 * This service manages location permissions, tracking,
 * and geocoding with proper error handling.
 */
export class LocationService {
  private static instance: LocationService;
  private locationSubscription: any = null;
  private currentLocation: LocationData | null = null;

  private constructor() {}

  static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }

  /**
   * Request location permissions
   */
  async requestLocationPermissions(): Promise<boolean> {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Location access is needed to tag tasks with your location.',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Settings', onPress: () => this.openSettings() },
          ]
        );
        return false;
      }
      return true;
    } catch (error) {
      console.error('Error requesting location permissions:', error);
      return false;
    }
  }

  /**
   * Get current location
   */
  async getCurrentLocation(): Promise<LocationData | null> {
    const hasPermission = await this.requestLocationPermissions();
    if (!hasPermission) return null;

    try {
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
        timeout: 10000,
        mayShowUserSettingsDialog: true,
      });

      const locationData: LocationData = {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        altitude: location.coords.altitude || undefined,
        accuracy: location.coords.accuracy || undefined,
        timestamp: location.timestamp,
      };

      this.currentLocation = locationData;
      return locationData;
    } catch (error) {
      console.error('Error getting location:', error);
      Alert.alert('Error', 'Failed to get your location');
      return null;
    }
  }

  /**
   * Start watching location updates
   */
  async startWatchingLocation(
    callback: (location: LocationData) => void,
    options: Location.LocationOptions = {
      accuracy: Location.Accuracy.Balanced,
      timeInterval: 5000,
      distanceInterval: 10,
    }
  ): Promise<boolean> {
    const hasPermission = await this.requestLocationPermissions();
    if (!hasPermission) return false;

    try {
      this.locationSubscription = await Location.watchPositionAsync(
        options,
        (location) => {
          const locationData: LocationData = {
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
            altitude: location.coords.altitude || undefined,
            accuracy: location.coords.accuracy || undefined,
            timestamp: location.timestamp,
          };
          
          this.currentLocation = locationData;
          callback(locationData);
        }
      );

      return true;
    } catch (error) {
      console.error('Error watching location:', error);
      return false;
    }
  }

  /**
   * Stop watching location updates
   */
  stopWatchingLocation() {
    if (this.locationSubscription) {
      this.locationSubscription.remove();
      this.locationSubscription = null;
    }
  }

  /**
   * Reverse geocode - get address from coordinates
   */
  async reverseGeocode(latitude: number, longitude: number): Promise<GeocodeResult | null> {
    try {
      const results = await Location.reverseGeocodeAsync({
        latitude,
        longitude,
      });

      if (results && results.length > 0) {
        const result = results[0];
        return {
          street: result.street,
          city: result.city,
          region: result.region,
          country: result.country,
          postalCode: result.postalCode,
          name: result.name,
        };
      }

      return null;
    } catch (error) {
      console.error('Error reverse geocoding:', error);
      return null;
    }
  }

  /**
   * Geocode - get coordinates from address
   */
  async geocode(address: string): Promise<LocationData | null> {
    try {
      const results = await Location.geocodeAsync(address);

      if (results && results.length > 0) {
        const result = results[0];
        return {
          latitude: result.latitude,
          longitude: result.longitude,
          timestamp: Date.now(),
        };
      }

      return null;
    } catch (error) {
      console.error('Error geocoding:', error);
      return null;
    }
  }

  /**
   * Calculate distance between two locations
   */
  calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) *
        Math.cos(this.toRadians(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    return distance;
  }

  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  /**
   * Get location permission status
   */
  async getPermissionStatus(): Promise<Location.PermissionStatus> {
    try {
      const { status } = await Location.getForegroundPermissionsAsync();
      return status;
    } catch (error) {
      console.error('Error getting permission status:', error);
      return 'undetermined';
    }
  }

  /**
   * Open app settings
   */
  private openSettings() {
    if (Platform.OS === 'ios') {
      // @ts-ignore
      Linking.openURL('app-settings:');
    } else {
      // @ts-ignore
      IntentLauncher.startActivityAsync(
        IntentLauncher.ActivityAction.APPLICATION_DETAILS_SETTINGS,
        { data: 'package:com.yourcompany.taskflow' }
      );
    }
  }
}

export const locationService = LocationService.getInstance();
```

### Location Picker Component

```typescript
// src/components/LocationPicker.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Platform,
  TextInput,
  Alert,
} from 'react-native';
import * as Location from 'expo-location';
import { locationService, LocationData, GeocodeResult } from '../services/locationService';

interface LocationPickerProps {
  onLocationSelected: (location: LocationData) => void;
  initialLocation?: LocationData | null;
  label?: string;
  showAddress?: boolean;
}

export const LocationPicker: React.FC<LocationPickerProps> = ({
  onLocationSelected,
  initialLocation = null,
  label = 'Location',
  showAddress = true,
}) => {
  const [location, setLocation] = useState<LocationData | null>(initialLocation);
  const [address, setAddress] = useState<GeocodeResult | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [isSearching, setIsSearching] = useState(false);

  // Load address when location changes
  useEffect(() => {
    if (location && showAddress) {
      loadAddress(location);
    }
  }, [location, showAddress]);

  const loadAddress = async (loc: LocationData) => {
    const result = await locationService.reverseGeocode(
      loc.latitude,
      loc.longitude
    );
    setAddress(result);
  };

  const handleGetCurrentLocation = async () => {
    setIsLoading(true);
    try {
      const currentLocation = await locationService.getCurrentLocation();
      if (currentLocation) {
        setLocation(currentLocation);
        onLocationSelected(currentLocation);
      }
    } catch (error) {
      console.error('Error getting location:', error);
      Alert.alert('Error', 'Failed to get your location');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSearchLocation = async () => {
    if (!searchText.trim()) {
      Alert.alert('Error', 'Please enter an address');
      return;
    }

    setIsSearching(true);
    try {
      const result = await locationService.geocode(searchText);
      if (result) {
        setLocation(result);
        onLocationSelected(result);
        setSearchText('');
      } else {
        Alert.alert('Error', 'Location not found');
      }
    } catch (error) {
      console.error('Error searching location:', error);
      Alert.alert('Error', 'Failed to search location');
    } finally {
      setIsSearching(false);
    }
  };

  const formatAddress = () => {
    if (!address) return 'Unknown location';
    
    const parts = [
      address.street,
      address.city,
      address.region,
      address.country,
    ].filter(Boolean);
    
    return parts.join(', ');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.label}>{label}</Text>

      {location ? (
        <View style={styles.locationDisplay}>
          <View style={styles.locationInfo}>
            <Text style={styles.coordinatesText}>
              📍 {location.latitude.toFixed(6)}, {location.longitude.toFixed(6)}
            </Text>
            {showAddress && (
              <Text style={styles.addressText}>{formatAddress()}</Text>
            )}
          </View>
          
          <TouchableOpacity
            style={styles.clearButton}
            onPress={() => {
              setLocation(null);
              setAddress(null);
              onLocationSelected(null as any);
            }}
          >
            <Text style={styles.clearText}>✕</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <View style={styles.locationInputContainer}>
          <TouchableOpacity
            style={styles.locationButton}
            onPress={handleGetCurrentLocation}
            disabled={isLoading}
          >
            {isLoading ? (
              <ActivityIndicator size="small" color="#ffffff" />
            ) : (
              <Text style={styles.locationButtonText}>Get Current Location</Text>
            )}
          </TouchableOpacity>

          <View style={styles.searchContainer}>
            <TextInput
              style={styles.searchInput}
              placeholder="Search for a location..."
              value={searchText}
              onChangeText={setSearchText}
              onSubmitEditing={handleSearchLocation}
              placeholderTextColor="#95a5a6"
            />
            <TouchableOpacity
              style={styles.searchButton}
              onPress={handleSearchLocation}
              disabled={isSearching}
            >
              {isSearching ? (
                <ActivityIndicator size="small" color="#ffffff" />
              ) : (
                <Text style={styles.searchButtonText}>Search</Text>
              )}
            </TouchableOpacity>
          </View>
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
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 8,
  },
  locationDisplay: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    padding: 12,
  },
  locationInfo: {
    flex: 1,
  },
  coordinatesText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  addressText: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 4,
  },
  clearButton: {
    padding: 8,
  },
  clearText: {
    fontSize: 16,
    color: '#e74c3c',
    fontWeight: '600',
  },
  locationInputContainer: {
    gap: 8,
  },
  locationButton: {
    backgroundColor: '#3498db',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  locationButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '500',
  },
  searchContainer: {
    flexDirection: 'row',
    gap: 8,
  },
  searchInput: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    fontSize: 14,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  searchButton: {
    backgroundColor: '#2ecc71',
    paddingHorizontal: 16,
    borderRadius: 8,
    justifyContent: 'center',
  },
  searchButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '500',
  },
});
```

---

## Target 3: Push Notifications

**The Target:** Implement push notifications for task reminders and updates.

**The Concept:** Push notifications are the most direct way to re-engage users. We'll implement them for task reminders, due date alerts, and team updates.

### Installation

```bash
npx expo install expo-notifications expo-device
```

### Notification Service

```typescript
// src/services/notificationService.ts
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform, Alert } from 'react-native';
import { appStorage } from '../utils/mmkvStorage';

export interface NotificationData {
  title: string;
  body: string;
  data?: Record<string, any>;
  sound?: boolean;
  badge?: number;
  categoryIdentifier?: string;
}

export interface ScheduledNotification extends NotificationData {
  id: string;
  trigger: Date;
}

/**
 * NotificationService - Handles push notifications
 * 
 * This service manages notification permissions, scheduling,
 * and handling of incoming notifications.
 */
export class NotificationService {
  private static instance: NotificationService;
  private expoPushToken: string | null = null;
  private notificationListener: any = null;
  private responseListener: any = null;

  private constructor() {
    this.setupNotificationHandlers();
  }

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  /**
   * Set up notification handlers
   */
  private setupNotificationHandlers() {
    // Set notification handler
    Notifications.setNotificationHandler({
      handleNotification: async () => ({
        shouldShowAlert: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
      }),
    });

    // Listen for notifications received while app is foregrounded
    this.notificationListener = Notifications.addNotificationReceivedListener(
      (notification) => {
        console.log('📱 Notification received:', notification);
        // Handle notification in foreground
        this.handleNotification(notification);
      }
    );

    // Listen for notification responses (user taps)
    this.responseListener = Notifications.addNotificationResponseReceivedListener(
      (response) => {
        console.log('🔔 Notification tapped:', response);
        // Navigate to appropriate screen
        this.handleNotificationResponse(response);
      }
    );
  }

  /**
   * Request notification permissions
   */
  async requestPermissions(): Promise<boolean> {
    try {
      const { status: existingStatus } = await Notifications.getPermissionsAsync();
      let finalStatus = existingStatus;

      if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
      }

      if (finalStatus !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Notifications are needed to remind you about tasks.',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Settings', onPress: () => this.openSettings() },
          ]
        );
        return false;
      }

      // Get Expo push token
      await this.getExpoPushToken();
      return true;
    } catch (error) {
      console.error('Error requesting notification permissions:', error);
      return false;
    }
  }

  /**
   * Get Expo push token
   */
  async getExpoPushToken(): Promise<string | null> {
    if (this.expoPushToken) {
      return this.expoPushToken;
    }

    try {
      if (!Device.isDevice) {
        console.log('📱 Must use physical device for push notifications');
        return null;
      }

      const token = await Notifications.getExpoPushTokenAsync({
        projectId: process.env.EXPO_PUBLIC_PROJECT_ID,
      });

      this.expoPushToken = token.data;
      
      // Save token locally
      appStorage.set('expo_push_token', token.data);
      
      // Register token with your backend
      await this.registerTokenWithBackend(token.data);

      console.log('✅ Expo push token:', token.data);
      return token.data;
    } catch (error) {
      console.error('Error getting push token:', error);
      return null;
    }
  }

  /**
   * Register token with backend
   */
  private async registerTokenWithBackend(token: string): Promise<void> {
    try {
      // In a real app, send token to your backend
      // await api.registerPushToken(token);
      console.log('📤 Registered token with backend:', token);
    } catch (error) {
      console.error('Error registering token:', error);
    }
  }

  /**
   * Send a local notification immediately
   */
  async sendNotification(notification: NotificationData): Promise<string | null> {
    try {
      const hasPermission = await this.requestPermissions();
      if (!hasPermission) return null;

      const { title, body, data, sound, badge } = notification;

      const notificationId = await Notifications.scheduleNotificationAsync({
        content: {
          title,
          body,
          data: data || {},
          sound: sound !== false,
          badge: badge || 1,
          categoryIdentifier: notification.categoryIdentifier,
        },
        trigger: null, // Send immediately
      });

      console.log('✅ Notification sent:', notificationId);
      return notificationId;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  }

  /**
   * Schedule a notification for a future time
   */
  async scheduleNotification(
    notification: NotificationData,
    trigger: Date
  ): Promise<string | null> {
    try {
      const hasPermission = await this.requestPermissions();
      if (!hasPermission) return null;

      const { title, body, data, sound, badge } = notification;

      const notificationId = await Notifications.scheduleNotificationAsync({
        content: {
          title,
          body,
          data: data || {},
          sound: sound !== false,
          badge: badge || 1,
          categoryIdentifier: notification.categoryIdentifier,
        },
        trigger: {
          date: trigger,
        },
      });

      // Save scheduled notification for reference
      const scheduled = this.getScheduledNotifications();
      scheduled.push({
        id: notificationId,
        title,
        body,
        data,
        trigger,
        sound,
        badge,
      });
      appStorage.set('scheduled_notifications', scheduled);

      console.log('📅 Notification scheduled:', notificationId, 'for', trigger);
      return notificationId;
    } catch (error) {
      console.error('Error scheduling notification:', error);
      return null;
    }
  }

  /**
   * Cancel a scheduled notification
   */
  async cancelNotification(notificationId: string): Promise<void> {
    try {
      await Notifications.cancelScheduledNotificationAsync(notificationId);
      
      // Remove from scheduled list
      const scheduled = this.getScheduledNotifications();
      const updated = scheduled.filter(n => n.id !== notificationId);
      appStorage.set('scheduled_notifications', updated);
      
      console.log('🗑️ Notification cancelled:', notificationId);
    } catch (error) {
      console.error('Error cancelling notification:', error);
    }
  }

  /**
   * Cancel all notifications
   */
  async cancelAllNotifications(): Promise<void> {
    try {
      await Notifications.cancelAllScheduledNotificationsAsync();
      appStorage.set('scheduled_notifications', []);
      console.log('🗑️ All notifications cancelled');
    } catch (error) {
      console.error('Error cancelling all notifications:', error);
    }
  }

  /**
   * Get scheduled notifications from storage
   */
  getScheduledNotifications(): ScheduledNotification[] {
    return appStorage.get<ScheduledNotification[]>('scheduled_notifications') || [];
  }

  /**
   * Handle received notification
   */
  private handleNotification(notification: Notifications.Notification): void {
    const data = notification.request.content.data;
    console.log('📱 Notification handled:', data);
    // Process notification data
  }

  /**
   * Handle notification response (user tapped)
   */
  private handleNotificationResponse(
    response: Notifications.NotificationResponse
  ): void {
    const data = response.notification.request.content.data;
    console.log('🔔 Notification response:', data);
    
    // Navigate based on notification data
    // Example: navigate to task detail
    if (data?.taskId) {
      // navigationService.navigate('TaskDetail', { taskId: data.taskId });
    }
  }

  /**
   * Schedule task reminder
   */
  async scheduleTaskReminder(
    taskId: string,
    taskTitle: string,
    dueDate: Date,
    daysBefore: number = 1
  ): Promise<string | null> {
    const reminderDate = new Date(dueDate);
    reminderDate.setDate(reminderDate.getDate() - daysBefore);

    // Don't schedule if reminder date is in the past
    if (reminderDate <= new Date()) {
      return null;
    }

    return this.scheduleNotification(
      {
        title: 'Task Due Soon',
        body: `"${taskTitle}" is due in ${daysBefore} day${daysBefore > 1 ? 's' : ''}`,
        data: { taskId, type: 'task_reminder' },
        sound: true,
        badge: 1,
        categoryIdentifier: 'task_reminder',
      },
      reminderDate
    );
  }

  /**
   * Open app settings
   */
  private openSettings() {
    if (Platform.OS === 'ios') {
      // @ts-ignore
      Linking.openURL('app-settings:');
    } else {
      // @ts-ignore
      IntentLauncher.startActivityAsync(
        IntentLauncher.ActivityAction.APPLICATION_DETAILS_SETTINGS,
        { data: 'package:com.yourcompany.taskflow' }
      );
    }
  }

  /**
   * Clean up listeners
   */
  cleanup() {
    if (this.notificationListener) {
      this.notificationListener.remove();
    }
    if (this.responseListener) {
      this.responseListener.remove();
    }
  }
}

export const notificationService = NotificationService.getInstance();
```

### Notification Permission Prompt

```typescript
// src/components/NotificationPermissionPrompt.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Platform,
  Modal,
  Animated,
} from 'react-native';
import { notificationService } from '../services/notificationService';

interface NotificationPermissionPromptProps {
  visible: boolean;
  onClose: () => void;
  onGranted?: () => void;
}

export const NotificationPermissionPrompt: React.FC<
  NotificationPermissionPromptProps
> = ({ visible, onClose, onGranted }) => {
  const [loading, setLoading] = useState(false);
  const [slideAnim] = useState(new Animated.Value(0));

  useEffect(() => {
    if (visible) {
      Animated.spring(slideAnim, {
        toValue: 1,
        useNativeDriver: true,
        tension: 65,
        friction: 10,
      }).start();
    }
  }, [visible]);

  const handleAllow = async () => {
    setLoading(true);
    try {
      const granted = await notificationService.requestPermissions();
      if (granted) {
        onGranted?.();
        onClose();
      }
    } catch (error) {
      console.error('Error requesting permissions:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      transparent
      visible={visible}
      animationType="fade"
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <Animated.View
          style={[
            styles.container,
            {
              transform: [
                {
                  translateY: slideAnim.interpolate({
                    inputRange: [0, 1],
                    outputRange: [100, 0],
                  }),
                },
              ],
              opacity: slideAnim,
            },
          ]}
        >
          <View style={styles.iconContainer}>
            <Text style={styles.icon}>🔔</Text>
          </View>

          <Text style={styles.title}>Stay Updated</Text>
          <Text style={styles.description}>
            Get notified about task deadlines, updates, and important reminders.
            You can change this anytime in settings.
          </Text>

          <View style={styles.buttonContainer}>
            <TouchableOpacity
              style={[styles.button, styles.allowButton]}
              onPress={handleAllow}
              disabled={loading}
            >
              <Text style={styles.allowButtonText}>
                {loading ? 'Processing...' : 'Allow Notifications'}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.skipButton} onPress={onClose}>
              <Text style={styles.skipButtonText}>Not Now</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.featuresContainer}>
            <View style={styles.featureItem}>
              <Text style={styles.featureIcon}>📅</Text>
              <Text style={styles.featureText}>Task Reminders</Text>
            </View>
            <View style={styles.featureItem}>
              <Text style={styles.featureIcon}>👥</Text>
              <Text style={styles.featureText}>Team Updates</Text>
            </View>
            <View style={styles.featureItem}>
              <Text style={styles.featureIcon}>⚡</Text>
              <Text style={styles.featureText}>Real-time Alerts</Text>
            </View>
          </View>
        </Animated.View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 24,
    padding: 24,
    width: '100%',
    maxWidth: 400,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 10 },
        shadowOpacity: 0.2,
        shadowRadius: 20,
      },
      android: {
        elevation: 10,
      },
    }),
  },
  iconContainer: {
    alignItems: 'center',
    marginBottom: 16,
  },
  icon: {
    fontSize: 48,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    textAlign: 'center',
    marginBottom: 8,
  },
  description: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
    marginBottom: 24,
    lineHeight: 20,
  },
  buttonContainer: {
    gap: 8,
  },
  button: {
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
  },
  allowButton: {
    backgroundColor: '#3498db',
  },
  allowButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  skipButton: {
    paddingVertical: 10,
  },
  skipButtonText: {
    color: '#95a5a6',
    fontSize: 14,
  },
  featuresContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 20,
    paddingTop: 20,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  featureItem: {
    alignItems: 'center',
  },
  featureIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  featureText: {
    fontSize: 12,
    color: '#7f8c8d',
  },
});
```

---

## Verification: Test Device APIs

```bash
# Run the app
cd ~/projects/TaskFlow
expo start
```

### Device API Test Checklist

1. **Camera:**
   - [ ] Permission prompt appears
   - [ ] Camera opens correctly
   - [ ] Photos save to local storage
   - [ ] Images display in attachments
   - [ ] Image removal works

2. **Photo Library:**
   - [ ] Permission prompt appears
   - [ ] Library opens correctly
   - [ ] Selected images display
   - [ ] Image optimization works

3. **Location:**
   - [ ] Permission prompt appears
   - [ ] Current location fetches correctly
   - [ ] Address reverse geocoding works
   - [ ] Location search works
   - [ ] Location tracking works

4. **Notifications:**
   - [ ] Permission prompt appears
   - [ ] Local notifications send
   - [ ] Notifications schedule for future
   - [ ] Notification tap navigation works
   - [ ] Cancel notification works

### Testing Commands

```bash
# Test camera in Expo Go
# Use the simulator's camera permission options

# Test location on simulator
# In iOS Simulator: Features → Location → Custom Location
# In Android Emulator: Extended Controls → Location

# Test notifications on physical device
# Send a test notification:
expo notifications:send
```

---

## What We've Accomplished

Congratulations! You've integrated core device capabilities into TaskFlow:

1. **Camera & Photos:** Capture and select images for task attachments
2. **Geolocation:** Tag tasks with location data and search addresses
3. **Notifications:** Send and schedule push notifications for task reminders
4. **Permissions:** Handle device permissions gracefully
5. **Image Optimization:** Compress and resize images for storage efficiency

### What's Next: Part 3, Phase 2 - Gestures & Animations

In the next phase, you'll learn:
- **React Native Gesture Handler:** Build fluid touch interactions
- **React Native Reanimated:** High-performance animations
- **Gesture-Driven Interfaces:** Swipe, drag, and pin gestures
- **Shared Element Transitions:** Smooth screen transitions

*Your app now has camera, location, and notification superpowers! Next, we'll make it feel truly native with fluid gestures and buttery-smooth animations. Your TaskFlow app will not only be functional but also delightful to use!*
