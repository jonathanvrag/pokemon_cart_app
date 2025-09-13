import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final String url;
  final String type;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.url,
    required this.type,
  });

  @override
  List<Object> get props => [id, name, imageUrl, url, type];
}
