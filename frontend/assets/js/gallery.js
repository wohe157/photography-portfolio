function galleryLoader() {
  // Set these to your API and image base URLs
  const API_BASE = window.GALLERY_API_BASE || '/api';
  const IMAGE_BASE = window.GALLERY_IMAGE_BASE || '/photos';

  return {
    groups: [],
    lightbox: null,
    lightboxGroup: null,
    lightboxIndex: null,
    async load() {
      const res = await fetch(`${API_BASE}/gallery`);
      const json = await res.json();
      this.groups = json.groups;
    },
    openLightbox(src, groupName, index) {
      this.lightbox = src;
      this.lightboxGroup = groupName;
      this.lightboxIndex = index;
    },
    closeLightbox() {
      this.lightbox = null;
      this.lightboxGroup = null;
      this.lightboxIndex = null;
    },
    nextLightbox() {
      const group = this.groups.find(g => g.name === this.lightboxGroup);
      if (!group) return;
      let nextIndex = this.lightboxIndex + 1;
      if (nextIndex >= group.images.length) nextIndex = 0;
      this.lightboxIndex = nextIndex;
      this.lightbox = `${IMAGE_BASE}/${group.name}/${group.images[nextIndex]}`;
    },
    prevLightbox() {
      const group = this.groups.find(g => g.name === this.lightboxGroup);
      if (!group) return;
      let prevIndex = this.lightboxIndex - 1;
      if (prevIndex < 0) prevIndex = group.images.length - 1;
      this.lightboxIndex = prevIndex;
      this.lightbox = `${IMAGE_BASE}/${group.name}/${group.images[prevIndex]}`;
    }
  }
}
