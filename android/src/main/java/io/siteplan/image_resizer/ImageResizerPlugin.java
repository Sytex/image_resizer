package io.siteplan.image_resizer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.media.ThumbnailUtils;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ImageResizerPlugin */
public class ImageResizerPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "io.siteplan.image_resizer");
    channel.setMethodCallHandler(new ImageResizerPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("resize")) {
      resize((String) call.argument("imagePath"), (String) call.argument("targetPath"), (int) call.argument("maxSize"), (int) call.argument("format"), result);
    } else {
      result.notImplemented();
    }
  }

  private Bitmap rotateImage(Bitmap source, float angle) {
      Matrix matrix = new Matrix();
      matrix.postRotate(angle);
      return Bitmap.createBitmap(
        source, 0, 0, source.getWidth(), source.getHeight(),matrix, true
      );
  }

  private void resize(String imagePath, String targetPath, int maxSize, int format, final Result result) {
    Bitmap imageBitmap = BitmapFactory.decodeFile(imagePath);
    try (FileOutputStream out = new FileOutputStream(targetPath)) {

      ExifInterface ei = new ExifInterface(imagePath);
      int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                                          ExifInterface.ORIENTATION_UNDEFINED);

      int width = imageBitmap.getWidth();
      int height = imageBitmap.getHeight();

      if(width > maxSize || height > maxSize) {
        if (width > height) {
            // landscape
            float ratio = (float) width / maxSize;
            width = maxSize;
            height = (int)(height / ratio);
        } else if (height > width) {
            // portrait
            float ratio = (float) height / maxSize;
            height = maxSize;
            width = (int)(width / ratio);
        } else {
            // square
            height = maxSize;
            width = maxSize;
        }
      }
      Bitmap resized = ThumbnailUtils.extractThumbnail(imageBitmap, width, height);

      Bitmap rotatedBitmap = null;
      switch(orientation) {
          case ExifInterface.ORIENTATION_ROTATE_90:
              rotatedBitmap = rotateImage(resized, 90);
              break;

          case ExifInterface.ORIENTATION_ROTATE_180:
              rotatedBitmap = rotateImage(resized, 180);
              break;

          case ExifInterface.ORIENTATION_ROTATE_270:
              rotatedBitmap = rotateImage(resized, 270);
              break;

          case ExifInterface.ORIENTATION_NORMAL:
          default:
              rotatedBitmap = resized;
      }

      rotatedBitmap.compress(format == 0 ? Bitmap.CompressFormat.JPEG : Bitmap.CompressFormat.PNG, 100, out);
      result.success(null);
    } catch (IOException e) {
      result.error("IOError", "Failed saving image", e.getMessage());
    }
  }
}
