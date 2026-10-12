package GameMode
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.MapResource;
   import Classes.VisitorManager;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Display.TakePhotoPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Helpers.Vector2;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Events.TakePhotoEvent;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import com.adobe.images.JPGEncoder;
   import com.facebook.Facebook;
   import com.facebook.commands.photos.CreateAlbum;
   import com.facebook.commands.photos.GetAlbums;
   import com.facebook.commands.photos.UploadPhoto;
   import com.facebook.commands.users.HasAppPermission;
   import com.facebook.data.BooleanResultData;
   import com.facebook.data.auth.ExtendedPermissionValues;
   import com.facebook.data.photos.AlbumData;
   import com.facebook.data.photos.GetAlbumsData;
   import com.facebook.data.photos.GetPhotosData;
   import com.facebook.events.FacebookEvent;
   import com.facebook.net.FacebookCall;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   
   public class GMSnapShot extends GMDefault
   {
      
      private static const SNAPSHOT_WIDTH:int = 600;
      
      private static const SNAPSHOT_HEIGHT:int = 400;
      
      private static const OUTLINE_WIDTH:int = 3;
      
      private static const OUTLINE_BORDER_WIDTH:int = 2;
      
      private static const UNKNOWN_ALBUMID:String = "-1";
      
      private static const INVALID_ALBUMID:String = "-2";
      
      private static const USER_PHOTOS_PERMISSION:String = "user_photos";
      
      private static var m_albumId:String = UNKNOWN_ALBUMID;
      
      private static var m_soundLoaded:Boolean = false;
      
      private var m_image:Sprite = new Sprite();
      
      private var m_snapShotObject:Sprite;
      
      private var m_snapshotPos:Vector2 = new Vector2();
      
      private var m_snapshotSize:Vector2 = new Vector2();
      
      private var m_hasPermissions:Boolean = false;
      
      private var m_requiredPermissions:Array;
      
      private var m_currentPermission:int;
      
      private var m_snapshot:ByteArray;
      
      private var m_album:AlbumData;
      
      private var m_fbook:Facebook = (GlobalEngine.socialNetwork as FacebookSocialNetwork).facebook;
      
      private var m_photoDialog:MovieClip;
      
      private var m_cancelButton:Loader;
      
      private var m_message:String;
      
      public function GMSnapShot()
      {
         if(!m_soundLoaded)
         {
            m_soundLoaded = true;
            SoundManager.addSound("camera",Global.getAssetURL("assets/sounds/actions/sfx_camera.mp3"),false);
         }
         this.m_requiredPermissions = new Array(ExtendedPermissionValues.PUBLISH_STREAM,USER_PHOTOS_PERMISSION);
         super(false);
         Global.ui.visible = false;
      }
      
      override public function enableMode() : void
      {
         var object:WorldObject = null;
         super.enableMode();
         var objects:Array = Global.world.getObjects();
         for each(object in objects)
         {
            if(object is MapResource)
            {
               (object as MapResource).prepForGameMode(this,true);
            }
         }
         this.onExtendedPermissionsCheck();
         FarmStatsManager.count("take_photo","start");
      }
      
      override public function disableMode() : void
      {
         var object:WorldObject = null;
         if(this.m_image.parent != null)
         {
            Global.stage.removeChild(this.m_image);
            this.m_image = null;
         }
         var objects:Array = Global.world.getObjects();
         for each(object in objects)
         {
            if(object is MapResource)
            {
               (object as MapResource).prepForGameMode(this,false);
            }
         }
         Global.ui.visible = true;
         super.disableMode();
      }
      
      override protected function updateOverlay() : void
      {
         if(this.m_snapShotObject != null)
         {
            this.m_snapShotObject.graphics.clear();
            this.m_snapShotObject.graphics.lineStyle(2 * 2,16711680);
            this.m_snapShotObject.graphics.moveTo(this.m_snapshotPos.x,this.m_snapshotPos.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x + this.m_snapshotSize.x,this.m_snapshotPos.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x + this.m_snapshotSize.x,this.m_snapshotPos.y + this.m_snapshotSize.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x,this.m_snapshotPos.y + this.m_snapshotSize.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x,this.m_snapshotPos.y);
            this.m_snapShotObject.graphics.lineStyle(2,16711680);
            this.m_snapShotObject.graphics.moveTo(this.m_snapshotPos.x,this.m_snapshotPos.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x + this.m_snapshotSize.x,this.m_snapshotPos.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x + this.m_snapshotSize.x,this.m_snapshotPos.y + this.m_snapshotSize.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x,this.m_snapshotPos.y + this.m_snapshotSize.y);
            this.m_snapShotObject.graphics.lineTo(this.m_snapshotPos.x,this.m_snapshotPos.y);
         }
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var pixelPos:Point = getMouseStagePos();
         var newPos:Vector2 = new Vector2(pixelPos.x - this.m_snapshotSize.x / 2,pixelPos.y - this.m_snapshotSize.y / 2);
         newPos.x = Utilities.clamp(newPos.x,0,Global.stage.stageWidth - this.m_snapshotSize.x);
         newPos.y = Utilities.clamp(newPos.y,0,Global.stage.stageHeight - this.m_snapshotSize.y);
         this.m_snapshotPos = newPos;
         this.updateOverlay();
         super.onMouseMove(event);
         return true;
      }
      
      override protected function getSelectableTypes() : int
      {
         return 0;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_PHOTO);
         SoundManager.playSound("camera");
         this.m_image.visible = false;
         if(this.m_cancelButton != null && this.m_cancelButton.parent != null)
         {
            Global.stage.removeChild(this.m_cancelButton);
         }
         var m_bitmapData:BitmapData = new BitmapData(this.m_snapshotSize.x,this.m_snapshotSize.y,true,0);
         var m_bitmapMatrix:Matrix = new Matrix();
         m_bitmapMatrix.translate(-this.m_snapshotPos.x,-this.m_snapshotPos.y);
         m_bitmapData.draw(Global.stage,m_bitmapMatrix,null,null,null,true);
         var m_jpgEncoder:JPGEncoder = new JPGEncoder(85);
         var m_jpgStream:ByteArray = m_jpgEncoder.encode(m_bitmapData);
         this.m_snapshot = m_jpgStream;
         this.m_photoDialog = new TakePhotoPopup(m_bitmapData);
         this.m_photoDialog.addEventListener(TakePhotoEvent.ACCEPT,this.onDialogAccept,false,0,true);
         this.m_photoDialog.addEventListener(TakePhotoEvent.CANCEL,this.onDialogCancel,false,0,true);
         if(m_albumId == UNKNOWN_ALBUMID)
         {
            this.getAlbums();
         }
         UI.displayPopup(this.m_photoDialog);
      }
      
      private function onDialogAccept(e:TakePhotoEvent) : void
      {
         this.m_message = e.data;
         this.uploadPhoto();
      }
      
      private function onDialogCancel(e:TakePhotoEvent) : void
      {
         var tempFert:int = 0;
         var tempFood:int = 0;
         Global.world.setDefaultGameMode();
         if(Global.worldManager.isVisiting())
         {
            tempFert = Global.player.fertilizer;
            Global.player.fertilizer = tempFert;
            Global.player.queuedFertilizer = Global.player.fertilizer;
            tempFood = Global.player.animalFood;
            Global.player.animalFood = tempFood;
            Global.player.queuedAnimalFood = Global.player.animalFood;
         }
         Global.ui.visible = true;
      }
      
      private function uploadPhoto(e:Event = null) : void
      {
         var m_queryString:String = null;
         var call:UploadPhoto = null;
         var tempFert:int = 0;
         var tempFood:int = 0;
         if(m_albumId == UNKNOWN_ALBUMID)
         {
            this.m_photoDialog.addEventListener(Event.ACTIVATE,this.uploadPhoto,false,0,true);
         }
         else
         {
            this.m_photoDialog.removeEventListener(Event.ACTIVATE,this.uploadPhoto);
         }
         if(m_albumId != UNKNOWN_ALBUMID && m_albumId != INVALID_ALBUMID)
         {
            if(Global.worldManager.isVisiting())
            {
               m_queryString = "?ref=takePhoto&visitId=" + Global.worldManager.getVisiting();
            }
            else
            {
               m_queryString = "?ref=takePhoto";
            }
            call = new UploadPhoto(this.m_snapshot,m_albumId,this.m_message);
            call.addEventListener(FacebookEvent.COMPLETE,this.onPhotoUploadComplete,false,0,true);
            this.m_fbook.post(call);
         }
         else
         {
            FarmStatsManager.count("PhotoTake","invalid_albumID",m_albumId);
         }
         if(Global.worldManager.isVisiting())
         {
            tempFert = Global.player.fertilizer;
            tempFood = Global.player.animalFood;
            Global.world.addGameMode(VisitorManager.getInstance().getVisitGM(),true);
            Global.player.fertilizer = tempFert;
            Global.player.queuedFertilizer = Global.player.fertilizer;
            Global.player.animalFood = tempFood;
            Global.player.queuedAnimalFood = Global.player.animalFood;
         }
         else
         {
            Global.world.addGameMode(new GMDefault(),true);
         }
         Global.ui.visible = true;
         FarmStatsManager.count("take_photo","upload");
      }
      
      private function onPhotoUploadComplete(e:FacebookEvent) : void
      {
         FarmStatsManager.count("take_photo","upload_complete");
      }
      
      private function getAlbums() : void
      {
         var call:FacebookCall = this.m_fbook.post(new GetAlbums(this.m_fbook.uid));
         call.addEventListener(FacebookEvent.COMPLETE,this.onGetAlbums,false,0,true);
      }
      
      private function onGetAlbums(e:FacebookEvent) : void
      {
         var albumData:AlbumData = null;
         var call:FacebookCall = null;
         var albumCreated:Boolean = false;
         var albumsResponseData:GetAlbumsData = e.data as GetAlbumsData;
         var albumName:String = ZLocUtils.t("FarmVille","FarmVillePhotos");
         if(!e.data || !albumsResponseData || albumsResponseData.albumCollection.length == 0)
         {
            m_albumId = INVALID_ALBUMID;
            FarmStatsManager.count("PhotoTake","fb_response_invalid");
         }
         for(var i:int = 0; i < albumsResponseData.albumCollection.length; i++)
         {
            albumData = albumsResponseData.albumCollection.getItemAt(i) as AlbumData;
            if(albumData.name == albumName)
            {
               m_albumId = albumData.aid;
               albumCreated = true;
               break;
            }
            if(albumData.aid == "")
            {
               m_albumId = INVALID_ALBUMID;
               FarmStatsManager.count("PhotoTake","fb_response_null");
            }
         }
         if(!albumCreated && m_albumId == UNKNOWN_ALBUMID)
         {
            m_albumId = INVALID_ALBUMID;
            call = this.m_fbook.post(new CreateAlbum(albumName));
            FarmStatsManager.count("PhotoTake","create_album");
            call.addEventListener(FacebookEvent.COMPLETE,this.onCreateAlbum);
         }
         else
         {
            this.m_photoDialog.dispatchEvent(new Event(Event.ACTIVATE));
         }
      }
      
      private function onCreateAlbum(e:FacebookEvent) : void
      {
         this.getAlbums();
      }
      
      private function handleGetPhotosResponse(e:FacebookEvent) : void
      {
         var photoItem:Object = null;
         var snapshot:String = null;
         var photoLink:String = null;
         var bundleData:Object = null;
         var photos:GetPhotosData = e.data as GetPhotosData;
         if(photos.photoCollection.length > 0)
         {
            photoItem = photos.photoCollection.getItemAt(photos.photoCollection.length - 1);
            snapshot = photoItem["src"];
            photoLink = photoItem["src_big"];
            bundleData = {
               "photo_link":photoLink,
               "images":[{
                  "href":photoLink,
                  "src":"http://www.static.zynga.com/img/home-card-new.png"
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("TakePhoto",bundleData,[],false);
         }
      }
      
      private function onExtendedPermissionsCheck(event:FacebookEvent = null) : void
      {
         var facebookSN:FacebookSocialNetwork = null;
         var call:FacebookCall = null;
         if(!event)
         {
            this.m_currentPermission = 0;
         }
         else
         {
            if(!(event.success && (event.data as BooleanResultData).value))
            {
               this.m_hasPermissions = false;
               UI.displayMessage(ZLocUtils.t("FarmGame","Snapshot_dialog"),1,this.onNewMessage);
               return;
            }
            ++this.m_currentPermission;
         }
         if(this.m_currentPermission < this.m_requiredPermissions.length)
         {
            facebookSN = GlobalEngine.socialNetwork as FacebookSocialNetwork;
            call = facebookSN.facebook.post(new HasAppPermission(this.m_requiredPermissions[this.m_currentPermission],facebookSN.facebook.uid));
            call.addEventListener(FacebookEvent.COMPLETE,this.onExtendedPermissionsCheck,false,0,true);
         }
         else
         {
            this.m_hasPermissions = true;
            this.createPhotoOutline();
         }
      }
      
      private function createPhotoOutline() : void
      {
         this.m_snapShotObject = new Sprite();
         this.m_image = this.m_snapShotObject;
         this.updateOverlay();
         Global.stage.addChild(this.m_image);
         this.m_snapshotSize.x = SNAPSHOT_WIDTH;
         this.m_snapshotSize.y = SNAPSHOT_HEIGHT;
         if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
         {
            Global.stage.displayState = StageDisplayState.NORMAL;
         }
         this.m_cancelButton = LoadingManager.load(Global.getAssetURL("assets/dialogs/Cancel_Bt.swf"),this.onCancelButtonAdded,LoadingManager.PRIORITY_HIGH);
      }
      
      private function onPhotoCancel(event:Event) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         Global.stage.removeChild(this.m_cancelButton);
         this.m_cancelButton.removeEventListener(MouseEvent.CLICK,this.onPhotoCancel);
         Global.world.removeGameMode(this);
         this.onDialogCancel(null);
      }
      
      private function onCancelButtonAdded(event:Event) : void
      {
         Global.stage.addChild(this.m_cancelButton);
         var botRightPt:Point = Global.ui.getBottomRight();
         this.m_cancelButton.x = botRightPt.x - this.m_cancelButton.width - 10;
         this.m_cancelButton.y = botRightPt.y - this.m_cancelButton.height - 10;
         this.m_cancelButton.addEventListener(MouseEvent.CLICK,this.onPhotoCancel,false,0,true);
      }
      
      private function onNewMessage(event:GenericPopupEvent) : void
      {
         var permissions:String = null;
         var i:int = 0;
         if(!event.button)
         {
            Global.world.removeGameMode(this);
            this.onDialogCancel(null);
         }
         else
         {
            this.createPhotoOutline();
            permissions = this.m_requiredPermissions[0];
            for(i = 1; i < this.m_requiredPermissions.length; i++)
            {
               permissions = permissions + "," + this.m_requiredPermissions[i];
            }
            GlobalEngine.socialNetwork.showStreamPermissions(null,permissions);
            FarmStatsManager.count("take_photo","prompt_permission");
         }
      }
   }
}

