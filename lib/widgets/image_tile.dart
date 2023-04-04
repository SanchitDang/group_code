import 'package:flutter/material.dart';

class ImageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;

  const ImageTile(
      {Key? key,
        required this.message,
        required this.sender,
        required this.sentByMe})
      : super(key: key);

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
        const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
                : const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[300]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style:  TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.sentByMe
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
        Container(
          child: widget.message != ""
              ? Image.network(
              widget.message)
              : const Center(child: CircularProgressIndicator(color: Colors.grey,)),
        ),

          ],
        ),
      ),
    );
  }
}
