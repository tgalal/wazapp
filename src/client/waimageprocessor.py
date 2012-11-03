from PIL import Image, ImageOps, ImageFilter
from wadebug import WADebug

class WAImageProcessor():
	squircleMaskPath = "/usr/share/themes/blanco/meegotouch/images/theme/basement/meegotouch-avatar/meegotouch-avatar-mask-small.png"
	squircleFramePath = "/usr/share/themes/blanco/meegotouch/images/theme/basement/meegotouch-avatar/meegotouch-avatar-frame-small.png"

	def __init__(self):
		WADebug.attach(self);
		self.squircleLoaded = False;
	
	
	def loadSquircle(self):
		self.squircleMask = Image.open(self.squircleMaskPath)
		self.squircleFrame = Image.open(self.squircleFramePath)
		
		self.squircleMask.load();
		self.squircleFrame.load();
		
		self.squircleLoaded = True

		return True;

	def createSquircle(self, source, destination):
		
		if not self.squircleLoaded: 
			self._d("Squircler is not loaded, loading")
			if not self.loadSquircle(): return

		self.maskImage(source, destination, self.squircleMask, self.squircleFrame)


	def maskImage(self, source, destination, mask, frame):
		if type(source) in (str, unicode):
			source = Image.open(source)
			source.load()
		
		if type(mask) in (str,unicode):
			mask = Image.open(mask)
			mask.load()
		
		if type(frame) in (str, unicode):
			frame = Image.open(frame)
			frame.load()

		mask = mask.filter(ImageFilter.SMOOTH)
		croppedImage = ImageOps.fit(source, mask.size, method=Image.ANTIALIAS)
		croppedImage = croppedImage.convert("RGBA")
		
		r,g,b,a = mask.split()
		
		croppedImage.paste(frame, mask=a)
		croppedImage.save(destination)
