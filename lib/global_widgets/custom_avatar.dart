import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';


Future<Uint8List?> selectAvatar(ImageSource imageSource) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? xfile = await imagePicker.pickImage(source: imageSource);

  if(xfile != null) {
    return await xfile.readAsBytes();
  }
  else{
    return null;
  }
}

/*selectAvatar(ImageSource imageSource) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? xfile = await imagePicker.pickImage(source: imageSource);

  if(xfile != null) {
    return await xfile.readAsBytes();
  }
  else{
    return null;
  }
}*/


