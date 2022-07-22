import 'package:flutter/material.dart';
import 'package:movies_app/providers/movies_provider.dart';
import 'package:movies_app/search/search_delegate.dart';
import 'package:movies_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Peliculas en cine'),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () => showSearch(
                    context: context, delegate: MovieSearchDelegate()),
                icon: const Icon(Icons.search_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CardSwiper(movies: movieProvider.onDisplayMovies),
              MovieSlider(
                movies: movieProvider.popularMovies,
                onNextPage: () => movieProvider.getPopularMovies(),
                title: 'Populares',
              ),
            ],
          ),
        ));
  }
}
