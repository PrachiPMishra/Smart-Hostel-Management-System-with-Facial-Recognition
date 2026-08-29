# Facial Recognition Worker

This worker processes CCTV camera feeds and performs facial recognition for attendance tracking.

## Architecture

The worker:
1. Connects to RTSP camera streams
2. Detects faces in frames
3. Extracts face embeddings using the recognition model
4. Matches embeddings against enrolled users in the database
5. Reports recognized faces to the backend API
6. Flags unknown faces for review

## User Model Integration

### Recognition Adapter

The `recognition_adapter.py` provides a standardized interface for your facial recognition model. You need to implement:

1. **Model Loading** (`load` method):
   ```python
   def load(self, model_path: str):
       # Load your trained model
       import pickle
       with open(model_path, 'rb') as f:
           self.model = pickle.load(f)
   ```

2. **Embedding Extraction** (`_extract_embedding` method):
   ```python
   def _extract_embedding(self, image: np.ndarray) -> List[float]:
       # Preprocess image
       preprocessed = preprocess_face(image)
       # Extract embedding using your model
       embedding = self.model.predict(preprocessed)
       return embedding.flatten().tolist()
   ```

3. **Embedding Matching** (`_match_embedding` method):
   ```python
   def _match_embedding(self, embedding: List[float], threshold: float) -> tuple:
       # Query database for similar embeddings
       # Return (user_id, confidence) if match found
       pass
   ```

### Model Types Supported

- **Deep Learning Models**: PyTorch, TensorFlow, ONNX
- **Traditional ML**: scikit-learn, pickle-based models
- **Pre-trained Models**: FaceNet, ArcFace, VGGFace, etc.

### Example: Using FaceNet

```python
import torch
from facenet_pytorch import InceptionResnetV1

class FaceNetAdapter(RecognitionAdapter):
    def load(self, model_path: str):
        self.model = InceptionResnetV1(pretrained='vggface2').eval()
    
    def _extract_embedding(self, image: np.ndarray):
        # Convert to tensor
        img_tensor = torch.tensor(image).permute(2, 0, 1).unsqueeze(0).float()
        # Extract embedding
        with torch.no_grad():
            embedding = self.model(img_tensor)
        return embedding.squeeze().numpy().tolist()
```

## Configuration

Edit `config.py` or use environment variables:

```bash
export BACKEND_URL="http://backend:8000"
export MODEL_PATH="/models/my_model.pkl"
export CAMERA_ENTRANCE="rtsp://192.168.1.100:554/stream"
export PROCESSING_INTERVAL=5
```

## Running

### Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run worker
python worker.py
```

### Docker

```bash
# Build
docker build -t hostel-recognition-worker .

# Run
docker run -e BACKEND_URL=http://backend:8000 \
           -v ./models:/models \
           hostel-recognition-worker
```

## Camera Configuration

### RTSP Stream URLs

Configure your CCTV cameras to provide RTSP streams:

```python
CAMERA_STREAMS = {
    "entrance": "rtsp://admin:password@192.168.1.100:554/stream",
    "mess_hall": "rtsp://admin:password@192.168.1.101:554/stream",
    "corridor_1": "rtsp://admin:password@192.168.1.102:554/stream",
}
```

### Supported Protocols

- RTSP (Real-Time Streaming Protocol)
- HTTP/HTTPS streams
- Local video files (for testing)

## Performance Optimization

- **Frame Rate**: Adjust `PROCESSING_INTERVAL` to balance accuracy and performance
- **Face Detection**: Use GPU-accelerated detectors (MTCNN, RetinaFace)
- **Parallel Processing**: Process multiple cameras in parallel using multiprocessing
- **Batch Processing**: Process multiple faces in a single batch for efficiency

## Security & Privacy

- All face embeddings are encrypted before storage
- Camera streams use authenticated RTSP connections
- Unknown faces are flagged but require manual review
- Automatic data retention policies clean old data

## Troubleshooting

### Camera Connection Issues

```python
# Test RTSP stream
import cv2
cap = cv2.VideoCapture("rtsp://192.168.1.100:554/stream")
if cap.isOpened():
    print("Stream connected")
```

### Model Loading Errors

- Ensure model file exists at `MODEL_PATH`
- Check model format matches your adapter implementation
- Verify all dependencies are installed

### Performance Issues

- Reduce `PROCESSING_INTERVAL` to process fewer frames
- Use smaller face detection models
- Enable GPU acceleration if available
