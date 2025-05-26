String formatVolume(int volume) {
  if (volume >= 1000000000) {
    return '${(volume / 1000000000).toStringAsFixed(2)}B';
  } else if (volume >= 1000000) {
    return '${(volume / 1000000).toStringAsFixed(2)}M';
  } else if (volume >= 1000) {
    return '${(volume / 1000).toStringAsFixed(2)}K';
  }
  return volume.toString();
}
