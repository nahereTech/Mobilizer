import 'dart:async';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/comments/comments_of_post_response.dart';
import 'package:mobilizer/models/comments/create_comments_request.dart';
import 'package:mobilizer/models/feed/feed_details_response.dart' as details;
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/notifications/notifications.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:mobilizer/widget/edit_video.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class PostNotificationScreen extends StatefulWidget {
  PostNotificationScreen({Key? key}) : super(key: key);

  static String routeName = 'push_notification_screen';

  @override
  _PostNotificationScreenState createState() => _PostNotificationScreenState();
}

class _PostNotificationScreenState extends State<PostNotificationScreen> {
  bool isCommentExpanded = false;
  bool _showBottomMenu = true;

  var messageTextController = TextEditingController();
  final _controllerComment = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  details.FData? _postData;
  ScrollController _scrollController = ScrollController();
  late String messageText;
  late List<String> _imageUrls;

  // List<CommentOfPostData> comments = [];
  List<FeedData> comments = [];
  List<dynamic> postImages = [];
  List<dynamic> postImageList = [];
  List<dynamic> imageList = [];
  List<Like> postLikeCounts = [];
  List<Like> likeCounts = [];
  List<Comment> commentCounts = [];
  List<ShareP> shareCounts = [];
  List<MediaItem> images = [];
  List<int> _mediaErrors = [];
  List<MediaItem> editedMediaList = [];

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  bool loading = true;
  bool _isLoadingComments = true;
  bool _isLoadingOlderComments = false;
  bool _isSending = false;
  bool _mediaHasError = false;
  bool noResult = true;
  bool isLoadingUpRequest = true;
  bool newLoader = true;
  bool firstTimeLoading = false;
  bool olderLoader = false;
  bool isThereResult = false;
  bool isLastDownRequest = false;

  String post_id = '';
  String comment_id = '';
  String direction = '';
  String n_type = '';
  int _subjectID = -1;
  int _limit = 5;
  int _nextPage = 1;
  int _newNextPage = -1;
  int _clickedID = 0;

  Timer? timer;
  var moment = new Moment.now();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    // imageList = args['media'];
    // print("My images: " + imageList.length.toString());
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      n_type = args['n_type'];
      post_id = args['n_type'] == "post" ? args['item_id'] : '';
      comment_id = args['n_type'] == "comment" ? args['item_id'] : '';
      print("Po ${post_id}");
      print("MapData: ${args['post_message']}");
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        //setState(() {
        moment = Moment.now();
        //});
      });
      //print("Image Name: " + postImages[0].name);
      BlocProvider.of<PostsBloc>(context).add(
        GetPostDetailsEvent(post_id: post_id, the_comment_id: comment_id),
      );
      setState(() {
        //_nType = args['n_type'];
        AppSharedPreferences.setValue(key: 'orgID', value: args['org_id']);
        AppSharedPreferences.setValue(key: 'orgName', value: args['org_name']);
        AppSharedPreferences.setValue(
            key: 'groupID', value: args['townhall_id']);
      });
      BlocProvider.of<PostsBloc>(context).add(
        GetPostCommentsEvent(
            postID: post_id,
            limit: _limit,
            orderBy: '',
            page: _nextPage,
            multidimensional: ''),
      );
      _scrollController.addListener(_scrollListener);
    });
    super.initState();
  }

  void _scrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getOlderComments();
      } else if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        //_getNewerComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("$n_type"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.timeline_outlined),
            onPressed: () {
              // Add your onPressed callback here
            },
          ),
        ],
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is LoadingState) {
            loading = true;
          }
          if (state is PostDetailsState) {
            _postData = state.postResponse.data!;
            if (_postData!.post_images != null) {
              postImages = _postData!.post_images!;
              if (postImages.length > 0) {
                for (var i = 0; i < postImages.length; i++) {
                  postImageList.add({
                    'name': postImages[i].name,
                    'type': postImages[i].type,
                    'thumbnail': postImages[i].thumbnail,
                  });
                }

                debugPrint("Post Images: ${postImageList}");
              }
            }
            // showShimmerLoader = false;

            // print(
            //     "is there result: Loading:  older_newer: ${older_or_newer}");
          } else if (state is CreateCommentState) {
            setState(() {
              _isSending = false;
              noResult = false;
              comments.insert(
                0,
                FeedData(
                    post_id: state.createCommentsResponse.data!.post_id,
                    post_message:
                        state.createCommentsResponse.data!.post_message,
                    post_alignment:
                        state.createCommentsResponse.data!.post_alignment,
                    like_count: state.createCommentsResponse.data!.like_count,
                    is_liked: state.createCommentsResponse.data!.user_liked,
                    //updated_at: state.createCommentsResponse.data.updated_at,
                    post_updated_time:
                        state.createCommentsResponse.data!.post_updated_time,
                    posted_by: state.createCommentsResponse.data!.posted_by,
                    post_update_by:
                        state.createCommentsResponse.data!.post_update_by,
                    username: state.createCommentsResponse.data!.username,
                    post_profile_pics:
                        state.createCommentsResponse.data!.post_profile_pics,
                    comment_count:
                        state.createCommentsResponse.data!.comment_count,
                    can_delete: state.createCommentsResponse.data!.can_delete,
                    share_count: 0,
                    sharelink: state.createCommentsResponse.data!.share_link,
                    poll: '',
                    poll_end: '',
                    user_option: 0,
                    user_voted: false,
                    total_votes: 0),
              );
              images = [];
              isCommentExpanded = false;
              messageTextController.clear();
              likeCounts.insert(
                  0,
                  Like(
                      isLiked: state.createCommentsResponse.data!.user_liked,
                      likeCounts: state.createCommentsResponse.data!.like_count,
                      id: state.createCommentsResponse.data!.post_id));

              commentCounts.insert(
                  0,
                  Comment(
                      counts: state.createCommentsResponse.data!.comment_count,
                      id: state.createCommentsResponse.data!.post_id));
              shareCounts.insert(
                  0,
                  ShareP(
                      id: state.createCommentsResponse.data!.post_id,
                      counts: 0));
            });
            final snackBar = SnackBar(
              content: Text('Reply was successfully'),
              backgroundColor: Colors.green.shade300,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state is NetworkState) {
            loading = false;
          } else if (state is LoadedCommentsState) {
            _isLoadingComments = false;
            _isLoadingOlderComments = false;
            loading = false;
            noResult = false;
            // print(state.commentsResponse.msg);
            // print(state.commentsResponse.status);

            if (state.commentsResponse!.length > 0) {
              _nextPage = _nextPage + 1;

              comments.addAll(state.commentsResponse!);
            }
          } else if (state is NoResultState) {
            _isLoadingComments = false;
            _isLoadingOlderComments = false;
            noResult = false;
          } else if (state is DeleteCommentState) {
            loading = false;
            print(state.deleteCommentResponse.msg);
            print(state.deleteCommentResponse.status);
            print(comments.length);
            BlocProvider.of<PostsBloc>(context).add(
              GetCommentEvent(
                post_id: post_id,
                limit: 1000,
                direction: direction,
              ),
            );
          } else if (state is AbuseReportState) {
            Navigator.of(context, rootNavigator: true).pop();
            final snackBar = SnackBar(
              content: Text('Post was successfully reported'),
              backgroundColor: Colors.green.shade300,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _controllerComment.text = '';
          } else if (state is BlockUserState) {
            final snackBar = SnackBar(
              backgroundColor: Color.fromARGB(255, 85, 207, 158),
              content: Text('User was successfully blocked'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state is NetworkState) {
            loading = false;
            noResult = false;
            _isLoadingComments = false;
            _isLoadingOlderComments = false;
            // print(state.message);
            // final snackBar = SnackBar(
            //   behavior: SnackBarBehavior.floating,
            //   margin: EdgeInsets.only(bottom: 10.0),
            //   content: Text(state.message.toString()),
            //   backgroundColor: Color(0xFFcf5555),
            // );
            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state is ErrorState) {
            loading = false;
            noResult = false;
            _isLoadingComments = false;
            _isLoadingOlderComments = false;
            if (state.errorFor == "like" || state.errorFor == "unlike") {
              _toggleLike(_subjectID);
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_postData != null) _buildMainPost(),
                    SizedBox(height: 10.0),
                    if (state is NoResultState)
                      Center(
                        child: Text("No comment"),
                      ),
                    if (_isLoadingComments && _isLoadingOlderComments == false)
                      Container(height: 300, child: _buildShimmerLoader()),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        likeCounts.add(Like(
                            isLiked: comments[index].is_liked,
                            likeCounts: comments[index].like_count,
                            id: comments[index].post_id));
                        commentCounts.add(Comment(
                            counts: comments[index].comment_count,
                            id: comments[index].post_id));
                        shareCounts.add(ShareP(
                            id: comments[index].post_id,
                            counts: comments[index].share_count));
                        //comment array index
                        return Column(
                          children: [
                            if (_isLoadingComments == false &&
                                comments.length < 1)
                              Center(
                                child: Text(
                                  "No comments",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            if (comments.length > 0)
                              GestureDetector(
                                onTap: () {
                                  print("object");
                                },
                                child: _buildComment(
                                    index,
                                    comments[index].post_update_by,
                                    comments[index].username,
                                    comments[index].post_profile_pics,
                                    post_id,
                                    comments[index].post_id.toString(),
                                    comments[index].post_updated_time,
                                    comments[index].post_message,
                                    comments[index].can_delete,
                                    comments[index].post_alignment,
                                    comments[index].sharelink),
                              ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                if (_isLoadingOlderComments)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildOlderCommentShimmerLoader(),
                  )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
        child: _showBottomMenu
            ? BottomNavigation(
                page: Notifications.routeName, showBottomMenu: _showBottomMenu)
            : null,
      ),
    );
  }

  Widget _bottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
      child: BottomNavigation(
          page: Notifications.routeName, showBottomMenu: _showBottomMenu),
    );
  }

  Widget _buildMainPost() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    "${_postData!.post_profile_pics}",
                  ),
                  radius: 24,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${_postData!.post_update_by}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            '. ${_getTimeAgo(DateTime.parse(_postData!.post_updated_time))}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.0),
                      Text(
                        '@${_postData!.username}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: Align(
              alignment: _postData!.post_alignment == "ltr" ||
                      _postData!.post_alignment == null ||
                      _postData!.post_alignment == ""
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: InkWell(
                onLongPress: () {
                  FlutterClipboard.copy(_postData!.post_message).then(
                    (value) => GFToast.showToast('Copied', context,
                        toastPosition: GFToastPosition.BOTTOM,
                        textStyle:
                            TextStyle(fontSize: 15, color: GFColors.DARK),
                        backgroundColor: GFColors.LIGHT,
                        trailing: Icon(
                          Icons.notifications,
                          color: GFColors.SUCCESS,
                        )),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(04.0),
                  child: Linkify(
                    options: LinkifyOptions(humanize: false),
                    onOpen: _onOpen,
                    text: _postData!.post_message,
                    style: TextStyle(fontSize: 15),
                    textAlign: _postData!.post_alignment == "rtl"
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                ),
              ),
            ),
          ),
          if (imageList.length > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
              child: ImageSwipe(imageList: imageList),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment_outlined,
                        color: Colors.grey, size: 18.0),
                    SizedBox(width: 4.0),
                    Text('${numberFormat(_postData!.comment_count)}',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0)),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      child: Icon(
                          _postData!.is_liked == true
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: _postData!.is_liked == true
                              ? Colors.red
                              : Colors.grey,
                          size: 18.0),
                      onTap: () {
                        // setState(() {
                        //   _clickedID = index;
                        // });

                        // if (_isLikeList[index]['like'] == true) {
                        //   BlocProvider.of<PostsBloc>(context).add(
                        //     UnLikePostEvent(post_id: feeds.post_id),
                        //   );
                        //   _toggleLike(index);
                        // } else {
                        //   BlocProvider.of<PostsBloc>(context).add(
                        //     LikePostEvent(post_id: feeds.post_id),
                        //   );
                        //   _toggleLike(index);
                        // }
                      },
                    ),
                    SizedBox(width: 4.0),
                    Text('${numberFormat(_postData!.like_count)}',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.share_outlined, color: Colors.grey, size: 18.0),
                    SizedBox(width: 4.0),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == "report") {
                      showDialog(
                        context: context,
                        builder: (BuildContext contextTwo) {
                          return AlertDialog(
                            scrollable: true,
                            title: Text('Report'),
                            content: Container(
                              height: 175.0,
                              width: 350.0,
                              child: Column(
                                children: [
                                  Container(
                                    child: SizedBox(
                                      child: TextFormField(
                                        maxLength: 300,
                                        maxLines: 3,
                                        minLines: 1,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Comment',
                                            hintText: 'Enter Comment',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 10.0)),
                                        controller: _controllerComment,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter Comment';
                                            final snackBar = SnackBar(
                                              content:
                                                  Text('Please Enter Comment'),
                                              backgroundColor:
                                                  Colors.green.shade300,
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2.0,
                                  ),
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      style: raisedButtonStyleGreen,
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          BlocProvider.of<PostsBloc>(context)
                                              .add(
                                            ReportAbuseEvent(
                                                comment:
                                                    _controllerComment.text,
                                                post_id: _postData!.post_id,
                                                reported: _postData!.posted_by),
                                          );
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Submit',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (value == 'delete') {
                      setState(() {
                        _clickedID = _postData!.post_id;
                      });
                      BlocProvider.of<PostsBloc>(context).add(
                        DeleteFeedEvent(
                            post_id: _postData!.post_id,
                            posted_by: _postData!.posted_by),
                      );
                    } else if (value == 'block') {
                      BlocProvider.of<PostsBloc>(context).add(
                        BlockUserEvent(
                            subjectID: _postData!.posted_by, req_type: 'block'),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Report'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'block',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Block'),
                      ),
                    ),
                  ],
                  child: const Row(
                    children: [
                      Icon(Icons.more_vert_outlined,
                          color: Colors.grey, size: 18.0),
                      SizedBox(width: 4.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  Widget _buildComment(
      int indexID,
      String fullname,
      username,
      String profilePic,
      String postID,
      String commentID,
      String commentDate,
      String message,
      bool canDelete,
      String commentAlignment,
      String shareLink) {
    int arrIndex = likeCounts
        .indexWhere((likeCounts) => likeCounts.id == int.parse(commentID));
    int arrCIndex = commentCounts.indexWhere(
        (commentCounts) => commentCounts.id == int.parse(commentID));
    int arrSIndex = shareCounts
        .indexWhere((shareCounts) => shareCounts.id == int.parse(commentID));
    Map<String, dynamic> mapComment = {
      'id': commentID,
      'post_message': message,
      'like_count': likeCounts[arrIndex].likeCounts,
      'comment_count': commentCounts[arrCIndex].counts,
      'post_profile_pics': profilePic,
      'post_update_by': fullname,
      'post_updated_time': commentDate,
      'username': username,
      'post_alignment': commentAlignment,
      'is_comment_of_comment': true,
      'media': [],
    };
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (contextA) => PostsBloc(),
                ),
              ],
              child: Comments(
                mapData: mapComment,
              ),
            );
          }));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('${profilePic}'),
                ),
              ],
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$fullname',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '. ' + _getTimeAgo(DateTime.parse(commentDate)),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 1),
                  Text(
                    '@$username',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$message',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment_outlined,
                              color: Colors.grey, size: 18.0),
                          SizedBox(width: 4.0),
                          Text('${commentCounts[arrCIndex].counts}',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14.0)),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (likeCounts[arrIndex].isLiked) {
                                BlocProvider.of<PostsBloc>(context).add(
                                  UnLikeCommentEvent(comment_id: commentID),
                                );
                              } else {
                                BlocProvider.of<PostsBloc>(context).add(
                                  LikeCommentEvent(comment_id: commentID),
                                );
                              }
                              _toggleLike(likeCounts[arrIndex].id);
                            },
                            child: Icon(
                                likeCounts[arrIndex].isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: likeCounts[arrIndex].isLiked
                                    ? Colors.red
                                    : Colors.grey,
                                size: 18.0),
                          ),
                          SizedBox(width: 4.0),
                          Text('${likeCounts[arrIndex].likeCounts}',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14.0)),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              share(
                                shareLink,
                                '',
                              );
                              setState(() {
                                shareCounts.insert(
                                    arrSIndex,
                                    ShareP(
                                        id: shareCounts[arrSIndex].id,
                                        counts:
                                            shareCounts[arrSIndex].counts + 1));
                              });
                            },
                            child: Icon(Icons.share_outlined,
                                color: Colors.grey, size: 18.0),
                          ),
                          SizedBox(width: 4.0),
                          Text('${shareCounts[arrSIndex].counts}',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14.0)),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_outlined,
                            color: Colors.grey, size: 18.0),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'reply',
                            child: ListTile(
                              leading: Icon(Icons.star_border_outlined),
                              title: Text('Reply'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Report'),
                            ),
                          ),
                          if (canDelete)
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Delete'),
                              ),
                            ),
                        ],
                        onSelected: (String value) {
                          // Handle option selection here
                          print('Selected option: $value');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    double formHeight = isCommentExpanded ? 150.0 : 48.0;

    return Container(
      padding:
          const EdgeInsets.only(bottom: 8.0), // Adding padding at the bottom
      height: formHeight,
      color: Color.fromARGB(
          255, 125, 171, 240), // Background color of the bottom bar
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjusted to min

        children: [
          if (isCommentExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: messageTextController,
                  onTap: () {
                    setState(() {
                      isCommentExpanded = true;
                    });
                  },
                  style: const TextStyle(
                      color: Colors.black), // Set text color to black
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors
                        .white, // Set background color of the form field to white
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    // Handle comment text changes
                  },
                ),
              ),
            ),
          if (isCommentExpanded)
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (images.length > 0)
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 12),
                        child: Container(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: _mediaHasError &&
                                                      _mediaErrors
                                                          .contains(index)
                                                  ? Colors.red
                                                  : Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: _buildMediaPreview(
                                                  images[index])),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            color: Colors.red,
                                            icon: Icon(Icons.cancel),
                                            onPressed: () {
                                              // Add delete functionality here
                                              setState(() {
                                                int posIndex =
                                                    _mediaErrors.indexOf(index);
                                                if (posIndex != -1) {
                                                  _mediaHasError = false;
                                                  _mediaErrors
                                                      .removeAt(posIndex);
                                                }
                                                images.removeAt(
                                                    index); //this is just the dummy
                                                editedMediaList.removeAt(
                                                    index); //this the file that will eventually be upload to server
                                              });
                                            },
                                          ),
                                        ),
                                        images[index].type.toString() ==
                                                "MediaType.video"
                                            ? Positioned(
                                                bottom: 15,
                                                right: 10,
                                                child: Container(
                                                  width: 21,
                                                  height: 21,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                  ),
                                                  child: IconButton(
                                                    padding: EdgeInsets.only(
                                                        top: 1, left: 2),
                                                    iconSize: 17,
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () async {
                                                      var adjustedDurationInSeconds =
                                                          3.0;
                                                      // Add delete functionality here
                                                      // await TrimmerView(
                                                      //     file: images[index].file);
                                                      VideoPlayerController
                                                          controller =
                                                          VideoPlayerController
                                                              .file(
                                                                  images[index]
                                                                      .file);
                                                      await controller
                                                          .initialize();
                                                      int fileSizeInBytes =
                                                          await images[index]
                                                              .file
                                                              .length();
                                                      double fileSizeInMB =
                                                          fileSizeInBytes /
                                                              (1024 * 1024);
                                                      print(
                                                          "fileSize: ${fileSizeInMB}");

                                                      if (fileSizeInMB > 15) {
                                                        print("here");
                                                        double
                                                            originalVideoDurationInSeconds =
                                                            controller
                                                                .value
                                                                .duration
                                                                .inSeconds
                                                                .toDouble(); // Convert duration to seconds
                                                        print(
                                                            "Ori ${originalVideoDurationInSeconds}");

                                                        double val = controller
                                                                .value
                                                                .duration
                                                                .inSeconds /
                                                            (fileSizeInMB /
                                                                15.0);
                                                        setState(() {
                                                          adjustedDurationInSeconds =
                                                              val;
                                                        }); // Adjust duration based on file size
                                                        print(
                                                            "adj ${adjustedDurationInSeconds}");
                                                      }

                                                      // final result =
                                                      //     await Navigator.of(
                                                      //             context)
                                                      //         .push(
                                                      //   MaterialPageRoute(
                                                      //       builder: (context) {
                                                      //     return TrimmerView(
                                                      //         // start: 0.0,
                                                      //         startPos:
                                                      //             images[index]
                                                      //                 .startPos,
                                                      //         endPos:
                                                      //             images[index]
                                                      //                 .endPos,
                                                      //         file:
                                                      //             images[index]
                                                      //                 .file,
                                                      //         duration:
                                                      //             adjustedDurationInSeconds);
                                                      //   }),
                                                      // );
                                                      // if (result != null) {
                                                      //   if (_mediaErrors
                                                      //       .contains(index)) {
                                                      //     print("Am here F");
                                                      //     // Remove the element from the list
                                                      //     setState(() {
                                                      //       _mediaErrors
                                                      //           .remove(index);
                                                      //       _mediaHasError =
                                                      //           false;
                                                      //     });
                                                      //   }
                                                      //   int positionIndex = editedMediaList
                                                      //       .indexWhere((media) =>
                                                      //           media.indexID
                                                      //               .toString() ==
                                                      //           index
                                                      //               .toString());
                                                      //   if (positionIndex !=
                                                      //       -1) {
                                                      //     editedMediaList[
                                                      //                 positionIndex]
                                                      //             .fileSize =
                                                      //         await _getSize(
                                                      //             File(result[
                                                      //                 'editedFile']));

                                                      //     editedMediaList[
                                                      //                 positionIndex]
                                                      //             .file =
                                                      //         File(result[
                                                      //             'editedFile']);
                                                      //     editedMediaList[
                                                      //             positionIndex]
                                                      //         .wasEdited = true;
                                                      //     editedMediaList[
                                                      //                 positionIndex]
                                                      //             .startPos =
                                                      //         result[
                                                      //             'startValue'];
                                                      //     editedMediaList[
                                                      //                 positionIndex]
                                                      //             .endPos =
                                                      //         result[
                                                      //             'endValue'];
                                                      //     editedMediaList[
                                                      //                 positionIndex]
                                                      //             .type =
                                                      //         MediaType.video;
                                                      //     setState(() {});
                                                      //     debugPrint("Fi2: " +
                                                      //         editedMediaList[
                                                      //                 positionIndex]
                                                      //             .fileSize
                                                      //             .toString());
                                                      //   }
                                                      // }
                                                    },
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  SizedBox(),
                  Row(
                    children: [
                      // IconButton(
                      //   icon: const Icon(Icons.image),
                      //   onPressed: _isSending
                      //       ? null
                      //       : () async {
                      //           // Handle adding an image
                      //           if (images.length >= 4) {
                      //             final snackBar = SnackBar(
                      //               content: Text(
                      //                   'You have reached the maximum allowed files'),
                      //               backgroundColor: Colors.red,
                      //             );
                      //             ScaffoldMessenger.of(context)
                      //                 .showSnackBar(snackBar);
                      //           } else {
                      //             await gallery();
                      //           }
                      //         },
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ElevatedButton(
                          onPressed: _isSending
                              ? null
                              : () async {
                                  // Handle submit button pressed
                                  setState(() {
                                    _isSending = true;
                                  });
                                  var nw = await getTownhallView();
                                  var party_townhall =
                                      nw == "location" ? 'yes' : 'no';
                                  BlocProvider.of<PostsBloc>(context).add(
                                    AddCommentEvent(
                                      createCommentsRequest:
                                          CreateCommentsRequest(
                                              party_townhall: party_townhall,
                                              post_id: post_id,
                                              message:
                                                  messageTextController.text,
                                              //reply_to_comment: '',
                                              parent_id: '',
                                              // with_file: 'no'
                                              group: '',
                                              org_id: ''),
                                    ),
                                  );
                                },
                          child: Text(_isSending ? 'sending...' : 'Reply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (!isCommentExpanded)
            InkWell(
              onTap: () {
                setState(() {
                  isCommentExpanded = true;
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Write a comment...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
            ),
            title: Container(
              height: 16,
              color: Colors.grey[300],
            ),
            subtitle: Container(
              height: 12,
              color: Colors.grey[300],
            ),
            trailing: Container(
              width: 24,
              height: 24,
              color: Colors.grey[300],
            ),
          );
        },
      ),
    );
  }

  String _getTimeAgo(DateTime utcTime) {
    return moment.from(utcTime.toLocal());
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  String _substring(String char, int count, String pattern) {
    return char.length > count ? char.substring(0, count) + pattern : char;
  }

  Future<String?> getTownhallView() async {
    return await AppSharedPreferences.getValue(key: 'townhallView');
  }

  MediaType _getType(File file) {
    if (file.path.endsWith('.mp4') || file.path.endsWith('.mov')) {
      return MediaType.video;
    } else {
      return MediaType.image;
    }
  }

  Future<void> gallery() async {
    int i = 0;
    int z = 0;
    final List<XFile> medias = await _picker.pickMultipleMedia();

    if (medias != null) {
      if (medias.length > 4) {
        images.addAll(await Future.wait(medias.map((file) async {
          return MediaItem(
            indexID: z++,
            file: File(file.path),
            fileSize:
                await _getType(File(file.path)).toString() == 'MediaType.video'
                    ? await _getSize(File(file.path)) // Wait for size here
                    : 0.0,
            type: _getType(File(file.path)),
            wasEdited: false,
            startPos: 0.0,
            endPos: 0.0, // You need to implement this function
          );
        })));
        editedMediaList.addAll(await Future.wait(medias.map((file) async {
          return MediaItem(
            indexID: i++,
            file: File(file.path),
            fileSize:
                await _getType(File(file.path)).toString() == 'MediaType.video'
                    ? await _getSize(File(file.path)) // Wait for size here
                    : 0.0,
            type: _getType(File(file.path)),
            wasEdited: false,
            startPos: 0.0,
            endPos: 0.0, // You need to implement this function
          );
        })));
        setState(() {});
      }
    }
    // if (images.length > 4) {
    //   int orgCounts = images.length;
    //   for (int i = 4; i < orgCounts; i++) {
    //     setState(() {
    //       medias.removeAt(i);
    //     });
    //   }
    // }
  }

  Widget _buildOlderCommentShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          1,
          (index) => ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
            ),
            title: Container(
              height: 16,
              color: Colors.grey[300],
            ),
            subtitle: Container(
              height: 12,
              color: Colors.grey[300],
            ),
            trailing: Container(
              width: 24,
              height: 24,
              color: Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  Future<double> _getSize(File file) async {
    VideoPlayerController controller = VideoPlayerController.file(file);
    await controller.initialize();
    int fileSizeInBytes = await file.length();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB;
  }

  void _toggleLike(int id) {
    int index = likeCounts
        .indexWhere((likeCounts) => likeCounts.id == int.parse(id.toString()));
    setState(() {
      likeCounts.insert(
          index,
          Like(
              isLiked: likeCounts[index].isLiked ? false : true,
              likeCounts: likeCounts[index].isLiked
                  ? likeCounts[index].likeCounts - 1
                  : likeCounts[index].likeCounts + 1,
              id: id));
    });
  }

  Widget _buildMediaPreview(MediaItem media) {
    if (media.type == MediaType.video) {
      return VideoPreview(media: media);
    } else {
      return Image.file(
        media.file,
        fit: BoxFit.cover,
      );
    }
  }

  String numberFormat(int n) {
    String num = n.toString();
    int len = num.length;

    if (n >= 1000 && n < 1000000) {
      return num.substring(0, len - 3) +
          '.' +
          num.substring(len - 3, 1 + (len - 3)) +
          'k';
    } else if (n >= 1000000 && n < 1000000000) {
      return num.substring(0, len - 6) +
          '.' +
          num.substring(len - 6, 1 + (len - 6)) +
          'm';
    } else if (n > 1000000000) {
      return num.substring(0, len - 9) +
          '.' +
          num.substring(len - 9, 1 + (len - 9)) +
          'b';
    } else {
      return num.toString();
    }
  }

  void _getOlderComments() {
    if (_newNextPage == _nextPage) {
      //if another request is send and it's the same with ongoing new page request, cancel it.
      return;
    }
    _newNextPage = _nextPage;
    setState(() {
      _isLoadingOlderComments = true;
    });
    BlocProvider.of<PostsBloc>(context).add(
      GetPostCommentsEvent(
          postID: _postData!.post_id,
          limit: _limit,
          orderBy: '',
          page: _nextPage,
          multidimensional: ''),
    );
  }

  share(String text, String title) async {
    final box = context.findRenderObject() as RenderBox?;
    // final imageUrl = "https://empl-dev.site/image1.jpg";
    // final url = Uri.parse(imageUrl);
    // final response = await http.get(url);
    // final bytes = response.bodyBytes;
    // final temp = await getTemporaryDirectory();
    // final path = '${temp.path}/image.jpg';
    // File(path).writeAsBytesSync(bytes);
    // if (imageList.length > 0) {
    //   await Share.shareFiles([path],
    //       text: text,
    //       //subject: title,
    //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    // } else {
    final status = await Share.share(text,
        subject: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    //}
  }
}

class Like {
  bool isLiked;
  int likeCounts;
  int id; //post or comment ID

  Like({required this.isLiked, required this.likeCounts, required this.id});
}

class Comment {
  int counts;
  int id;
  Comment({required this.counts, required this.id});
}

class ShareP {
  int id; //post or comment ID
  int counts;
  ShareP({required this.id, required this.counts});
}

class MediaItem {
  int indexID;
  File file;
  MediaType type;
  double startPos;
  double endPos;
  bool wasEdited;
  double fileSize;

  MediaItem({
    required this.indexID,
    required this.file,
    required this.fileSize,
    required this.type,
    required this.startPos,
    required this.endPos,
    required this.wasEdited,
  });
}

enum MediaType { image, video }

class VideoPreview extends StatefulWidget {
  final MediaItem media;
  const VideoPreview({required this.media});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.media.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  // void _editVideo() async {
  //   final output = await VideoEditor.editVideo(
  //     widget.media.file.path,
  //     startTime: Duration(seconds: 0),
  //     endTime: _controller.value.duration,
  //   );

  //   if (output != null) {
  //     setState(() {
  //       _controller = VideoPlayerController.file(output)
  //         ..initialize().then((_) {
  //           setState(() {});
  //         });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        IconButton(
          iconSize: 50,
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: _togglePlayPause,
        ),
        // Positioned(
        //   bottom: 22,
        //   right: 5,
        //   child: IconButton(
        //     icon: Icon(Icons.edit),
        //     onPressed: () async {
        //       await TrimmerView(file: widget.media.file);
        //     },
        //   ),
        // ),
      ],
    );
  }
}
