import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/controllers/auth_controller.dart';
import 'package:tiktok_clone/views/screens/auth/profile_screen.dart';
import 'package:tiktok_clone/views/screens/auth/search_screen.dart';
import 'package:tiktok_clone/views/screens/auth/video_screen.dart';
import 'views/screens/auth/add_video_screen.dart';

List pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  //const Text('Messages Screen'),
  const Text('Profile Screen'),
  ProfileScreen(uid: authController.user.uid),
];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;
