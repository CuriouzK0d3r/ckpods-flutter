import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:ckpods_flutter/models/podcast.dart';

class PodcastService {
  static const String _baseUrl = 'https://itunes.apple.com/search';

  Future<List<Podcast>> searchPodcasts(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl?term=${Uri.encodeComponent(query)}&media=podcast&limit=50'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results
            .map((json) => Podcast.fromJson(json))
            .where((podcast) => podcast.feedUrl.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error searching podcasts: $e');
    }

    return [];
  }

  Future<List<Episode>> getEpisodes(Podcast podcast) async {
    if (podcast.feedUrl.isEmpty) return [];

    try {
      final response = await http.get(Uri.parse(podcast.feedUrl));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        return items
            .map((item) => Episode.fromXml(item, podcast.imageUrl))
            .toList();
      }
    } catch (e) {
      print('Error fetching episodes: $e');
    }

    return [];
  }
}
