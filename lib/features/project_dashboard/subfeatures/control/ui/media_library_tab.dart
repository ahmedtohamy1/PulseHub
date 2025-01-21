import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaLibraryTab extends StatefulWidget {
  final int projectId;

  const MediaLibraryTab({
    super.key,
    required this.projectId,
  });

  @override
  State<MediaLibraryTab> createState() => _MediaLibraryTabState();
}

class _MediaLibraryTabState extends State<MediaLibraryTab> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDashboardCubit>().getMediaLibrary(widget.projectId);
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _showUploadDialog(BuildContext context) {
    PlatformFile? selectedFile;
    String fileName = '';
    String description = '';

    // Capture the cubit before showing dialog
    final cubit = context.read<ProjectDashboardCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) =>
              BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
            listener: (context, state) {
              if (state is ProjectDashboardCreateMediaLibraryFileSuccess) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                cubit.getMediaLibrary(widget.projectId);
              } else if (state
                  is ProjectDashboardCreateMediaLibraryFileFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to upload file: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.upload_file,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Upload File'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedFile == null)
                    Center(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              selectedFile = result.files.first;
                              fileName = selectedFile!.name;
                            });
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Choose File'),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedFile!.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {
                                    selectedFile = null;
                                    fileName = '';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'File Name',
                            hintText: 'Enter file name without extension',
                            prefixIcon: const Icon(Icons.edit_document),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) =>
                              fileName = '$value.${selectedFile!.extension}',
                          controller: TextEditingController(
                            text: selectedFile!.name
                                .replaceAll('.${selectedFile!.extension}', ''),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Description (optional)',
                            hintText: 'Enter file description',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                          onChanged: (value) => description = value,
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                if (selectedFile != null)
                  FilledButton.icon(
                    onPressed: () async {
                      final token = await SharedPrefHelper.getSecuredString(
                          SharedPrefKeys.token);
                      cubit.createMediaLibraryFile(
                        token,
                        widget.projectId,
                        fileName,
                        description,
                        selectedFile!,
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardCreateMediaLibraryFileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProjectDashboardCreateMediaLibraryFileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload file: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProjectDashboardDeleteMediaLibrarySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context
              .read<ProjectDashboardCubit>()
              .getMediaLibrary(widget.projectId);
        } else if (state is ProjectDashboardDeleteMediaLibraryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete file: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProjectDashboardGetMediaLibraryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetMediaLibrarySuccess) {
          final files =
              state.getMediaLibrariesResponseModel.mediaLibraries ?? [];
          final isUploading =
              state is ProjectDashboardCreateMediaLibraryFileLoading;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_open,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Media Library',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${files.length} file${files.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isUploading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _showUploadDialog(context),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload File'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: files.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No files uploaded yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: () => _showUploadDialog(context),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload your first file'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          final isImage = file.fileName
                                      ?.toLowerCase()
                                      .endsWith('.jpg') ==
                                  true ||
                              file.fileName?.toLowerCase().endsWith('.jpeg') ==
                                  true ||
                              file.fileName?.toLowerCase().endsWith('.png') ==
                                  true ||
                              file.fileName?.toLowerCase().endsWith('.gif') ==
                                  true;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                if (file.fileUrl != null) {
                                  _downloadFile(file.fileUrl!);
                                }
                              },
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {
                                    if (file.fileUrl != null) {
                                      _downloadFile(file.fileUrl!);
                                    }
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.1),
                                        child: isImage && file.fileUrl != null
                                            ? Image.network(
                                                file.fileUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Center(
                                                        child:
                                                            Icon(Icons.error)),
                                              )
                                            : Center(
                                                child: Icon(
                                                  _getFileIcon(
                                                      file.fileName ?? ''),
                                                  size: 48,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                file.fileName ?? 'Unnamed file',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDate(file.createdAt),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              if (file.description != null) ...[
                                                const SizedBox(height: 12),
                                                Text(
                                                  file.description.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .errorContainer,
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .error,
                                                      minimumSize:
                                                          const Size(40, 40),
                                                    ),
                                                    onPressed: () {
                                                      // Capture the cubit before showing dialog
                                                      final cubit = context.read<
                                                          ProjectDashboardCubit>();

                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) =>
                                                                BlocProvider
                                                                    .value(
                                                          value: cubit,
                                                          child: AlertDialog(
                                                            title: const Text(
                                                                'Delete File'),
                                                            content: Text(
                                                                'Are you sure you want to delete "${file.fileName}"?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        dialogContext),
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                              FilledButton(
                                                                style: FilledButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .error,
                                                                ),
                                                                onPressed: () {
                                                                  if (file.mediaLibraryId !=
                                                                      null) {
                                                                    cubit.deleteMediaLibrary(
                                                                        file.mediaLibraryId!);
                                                                    Navigator.pop(
                                                                        dialogContext);
                                                                  }
                                                                },
                                                                child: const Text(
                                                                    'Delete'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete_outline,
                                                        size: 18),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }

        return Center(
          child: FilledButton.icon(
            onPressed: () {
              context
                  .read<ProjectDashboardCubit>()
                  .getMediaLibrary(widget.projectId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Load Media Library'),
          ),
        );
      },
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.article;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
