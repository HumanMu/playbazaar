import 'package:image_picker/image_picker.dart';

selectAvatar(ImageSource imageSource) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? xfile = await imagePicker.pickImage(source: imageSource);

  if(xfile != null) {
    return await xfile.readAsBytes();
  }
  else{
    return null;
  }
}


