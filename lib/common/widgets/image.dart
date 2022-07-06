import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildRectWidget(
    {required Widget child,
    double width: 60,
    double? height,
    double? radius,
    Color? background}) {
  if (height == null) height = width;
  if (radius == null) radius = width / 2;
  return Container(
    height: height,
    width: width,
    color: background,
    child: ClipRRect(
      child: child,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

Widget buildImageWidget(String? imagePath,
    {String? defaultImage, bool autoCache: true, BoxFit? fit}) {
  Widget w;
  if (imagePath == null || imagePath.isEmpty) {
    imagePath = defaultImage;
  }
  if (imagePath == null || imagePath.isEmpty) {
    w = Container(
      color: Colors.grey,
      child: IconButton(onPressed: () {}, icon: Icon(Icons.photo_filter)),
    );
  } else if (imagePath.startsWith('/')) {
    // 本地图片
    w = Image.file(File(imagePath), fit: fit);
  } else if (imagePath.startsWith('assets')) {
    w = Image.asset(imagePath, fit: fit);
  } else {
    w = autoCache
        ? CachedNetworkImage(
            fit: fit,
            imageUrl: imagePath,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
        : FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: imagePath,
            alignment: Alignment.topCenter,
            fit: fit,
          );
  }
  return w;
}

// ignore: must_be_immutable
class ImageWidget extends StatefulWidget {
  String? imagePath;
  Function(String?)? onImageSelected;
  ImageWidget({Key? key, this.imagePath, this.onImageSelected})
      : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ImagePicker _imagePicker = ImagePicker();

  setImage(XFile? image) {
    setState(() {
      if (image != null) widget.imagePath = image.path;
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(image!.path);
      }
    });
  }

  _takePhoto() async {
    setImage(await _imagePicker.pickImage(source: ImageSource.camera));
  }

  _openGallery() async {
    setImage(await _imagePicker.pickImage(source: ImageSource.gallery));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
            // isScrollControlled: true, //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
            shape: RoundedRectangleBorder(
              //圆角
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            context: context,
            builder: (context) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _takePhoto();
                        },
                        child: Text(
                          "拍照",
                          style: TextStyle(fontSize: 18),
                        )),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openGallery();
                        },
                        child: Text(
                          "从相册中选择",
                          style: TextStyle(fontSize: 18),
                        )),
                    Container(
                      color: Colors.grey[300],
                      height: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "取消",
                          style: TextStyle(fontSize: 18),
                        )),
                    Container(
                      height: 30,
                    )
                  ],
                ),
              );
            });
      },
      child: Container(
        width: width,
        height: width,
        child: buildImageWidget(widget.imagePath),
      ),
    );
  }
}
