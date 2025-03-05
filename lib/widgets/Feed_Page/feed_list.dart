import 'package:flutter/material.dart';

class FeedList extends StatelessWidget {
  const FeedList({
    super.key,
    required this.body,
    this.image,
    required this.color,
    required this.txtColor,
  });

  final String body;
  final Image? image;
  final Color color;
  final Color txtColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image == null) ...{
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: ListTile(
              leading: Image.asset("assets/images/Apoorv.png"),
              title: Text(
                body,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        } else ...{
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: ListTile(
              leading: Image.asset("assets/images/Apoorv.png"),
              title: Text(
                body,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 300,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 290,
                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: image!.image,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              )),
          const SizedBox(
            height: 20,
          ),
        }
      ],
    );
  }
}
