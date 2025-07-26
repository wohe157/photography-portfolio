function galleryLoader() {
  return {
    groups: [],
    lightbox: null,
    lightboxGroup: null,
    lightboxIndex: null,
    async load() {
      const res = await fetch('data/gallery.json');
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
      this.lightbox = `photos/${group.name}/${group.images[nextIndex]}`;
    },
    prevLightbox() {
      const group = this.groups.find(g => g.name === this.lightboxGroup);
      if (!group) return;
      let prevIndex = this.lightboxIndex - 1;
      if (prevIndex < 0) prevIndex = group.images.length - 1;
      this.lightboxIndex = prevIndex;
      this.lightbox = `photos/${group.name}/${group.images[prevIndex]}`;
    }
  }
}