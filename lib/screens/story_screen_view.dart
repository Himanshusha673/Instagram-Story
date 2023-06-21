import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../data.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class StoryScreen extends StatefulWidget {
  final List<Story>? stories;
  final User user;

  const StoryScreen({super.key, required this.stories, required this.user});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);

    final Story firstStory = widget.stories!.first;
    _loadStory(story: firstStory, animateToPage: false);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories!.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories![_currentIndex]);
          } else {
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => StoryScreen(
                    stories: stories,
                    user: users[currentUserIndex >= users.length
                        ? currentUserIndex = 0
                        : currentUserIndex++])));
            // _currentIndex = 0;
            // _loadStory(story: widget.stories![_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories![_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // onHorizontalDragStart: (_) {
        //   Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       builder: (context) => StoryScreen(
        //           stories: stories,
        //           user: users[currentUserIndex < 0 ? 0 : --currentUserIndex])));
        // },
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            log(currentUserIndex.toString() + "${users.length}");
            // Swiped right
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => StoryScreen(
                    stories: stories,
                    user: users[currentUserIndex <= 0
                        ? currentUserIndex = resetUserindex(currentUserIndex)
                        : --currentUserIndex])));
          } else {
            log(currentUserIndex.toString() + "${users.length}");

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => StoryScreen(
                    stories: stories,
                    user: users[currentUserIndex > users.length - 1
                        ? currentUserIndex = resetUserindex(currentUserIndex)
                        : currentUserIndex++])));
          }
        },
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories!.length,
              itemBuilder: (context, i) {
                final Story story = widget.stories![i];
                switch (story.media) {
                  case MediaType.image:
                    return CachedNetworkImage(
                      imageUrl: story.url,
                      fit: BoxFit.cover,
                    );
                  case MediaType.video:
                    if (_videoController != null &&
                        _videoController!.value.isInitialized) {
                      log("notnull video");
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController?.value.size.width,
                          height: _videoController?.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      );
                    }
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: widget.stories!
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            AnimatedBar(
                              animController: _animController,
                              position: i,
                              currentIndex: _currentIndex,
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 10.0,
                    ),
                    child: UserInfo(user: widget.user),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  // Comment and share options
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Comment option
                        GestureDetector(
                          onTap: () {
                            // Handle comment option action
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.comment,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Comment',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Share option
                        GestureDetector(
                          onTap: () {
                            // Handle share option action
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text('Share',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories![_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories!.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories![_currentIndex]);
        } else {
          // Out of bounds - loop story
          // You can also Navigator.of(context).pop() here
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => StoryScreen(
                  stories: stories,
                  user: users[
                      currentUserIndex % 3 == 0 ? 0 : currentUserIndex++])));
          // _currentIndex = 0;
          // _loadStory(story: widget.stories![_currentIndex]);
        }
      });
    } else {
      if (story.media == MediaType.video) {
        if (_videoController!.value.isPlaying) {
          _videoController?.pause();
          _animController.stop();
        } else {
          _videoController?.play();
          _animController.forward();
        }
      }
    }
  }

  void _loadStory({Story? story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    switch (story!.media) {
      case MediaType.image:
        //_animController.duration =story.duration;
        _animController.duration = const Duration(seconds: 10);
        _animController.forward();
        break;
      case MediaType.video:
        log("notnull video");
        _videoController = null;
        _videoController?.dispose();
        _videoController = VideoPlayerController.network(story.url)
          ..initialize().then((_) {
            setState(() {});
            if (_videoController!.value.isInitialized) {
              // _animController.duration = _videoController?.value.duration>;
              _animController.duration =
                  story.duration > const Duration(seconds: 30)
                      ? const Duration(seconds: 30)
                      : story.duration;
              _videoController?.play();
              _animController.forward();
            }
          });
        break;
    }
    if (animateToPage) {
      // if (_currentIndex == stories.length) {
      //   Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (context) => StoryScreen(
      //           stories: stories,
      //           user: users[currentUserIndex == users.length
      //               ? 0
      //               : currentUserIndex++])));
      // } else {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
  //}
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[300],
          backgroundImage: CachedNetworkImageProvider(
            user.profileImageUrl,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

int resetUserindex(int currentIndexofUser) {
  currentIndexofUser = 0;
  return currentIndexofUser;
}
