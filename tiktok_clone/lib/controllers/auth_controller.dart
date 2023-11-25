import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user.dart' as model;
import 'package:tiktok_clone/views/screens/auth/login_screen.dart';
import 'package:tiktok_clone/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  late Rx<File?> _pickedImage;
  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;
  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar(
        'Lấy ảnh từ máy',
        'Bạn đã lấy ảnh thành công',
      );
    }
    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }

  // uPLOAD FILE CHO FIREBASE STORAGE
  Future<String> _uploadToStorage(File image) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // ĐĂNG KÝ CHO NGƯỜI DÙNG
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // LƯU VÀO FIREBASE ATH and firebase firestore
        UserCredential credential =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: credential.user!.uid,
          profilePhoto: downloadUrl,
        );
        await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());
        Get.snackbar(
          "Tạo tài khoảng thành công",
          "Chúc mừng bạn đã tạo tài khoảng thành công",
        );
        Get.to(LoginScreen());
      } else {
        Get.snackbar(
          "Tạo tài khoảng không thành công",
          "Lỗi khi tạo. Vui lòng tạo lại!!!",
        );
      }
    } catch (error) {
      Get.snackbar(
        "Tạo tài khoảng không thành công",
        error.toString(),
      );
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Get.snackbar(
          "Đăng nhập thành công",
          "Bạn đã đăng nhập thành công",
        );
        Get.to(const HomeScreen());
      } else {
        Get.snackbar(
          "Đăng nhập không thành công",
          "Lỗi khi đăng nhập!!!",
        );
      }
    } catch (error) {
      Get.snackbar(
        "Đăng nhập không thành công",
        error.toString(),
      );
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
