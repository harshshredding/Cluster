// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';


class InfoView extends StatelessWidget {
  final int id;

  const InfoView(this.id);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text("hello"),
              Spacer(),
              Text("hello"),
            ],
          ),
          SizedBox(height: 8),
          Text("he"),
          SizedBox(height: 8),
          Text("he"),
          SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save'),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final int id;

  DetailsScreen(this.id);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            left: 0,
            child: Image.network(
              'https://picsum.photos/250?image=9',
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              children: [
                 InfoView(widget.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}