import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';

class AcSearchBar extends StatefulWidget {
  final String? value;
  final void Function(String? value) onSearch;
  const AcSearchBar({super.key, required this.value, required this.onSearch});

  @override
  State<AcSearchBar> createState() => _AcSearchBarState();
}

class _AcSearchBarState extends State<AcSearchBar> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: AcInputBorderFactory(context, AcInputBorderType.outline,
                    borderRadius: const BorderRadius.all(AcSizes.brCircle))
                .decorate(
              InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon:
                      Icon(Icons.search, color: context.colors.tertiary)),
            ),
            onSubmitted: (value) {
              widget.onSearch(value.isEmpty ? null : value);
            },
          ),
        ),
        // const SizedBox(width: AcSizes.space),
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(
        //     Icons.filter_list,
        //   ),
        //   color: context.colors.primary,
        //   iconSize: AcSizes.iconBig,
        // )
      ],
    );
  }
}
