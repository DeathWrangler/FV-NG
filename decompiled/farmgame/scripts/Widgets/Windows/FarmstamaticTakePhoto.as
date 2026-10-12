package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Farmstamatic.FarmstamaticPhoto;
   import Classes.Farmstamatic.IFarmstamaticFeatureComponent;
   import Classes.Idle.IdleTaskQueue;
   import Classes.util.ExternalUtil;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import GameMode.GMDefault;
   import GameMode.GMFarmstamatic;
   import GameMode.GameMode;
   import Managers.FarmstamaticManager;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class FarmstamaticTakePhoto extends Sprite
   {
      
      public static const PHOTO_SIZE_X:int = 420;
      
      public static const PHOTO_SIZE_Y:int = 420;
      
      public static const ASSET_URL:String = "assets/dialogs/FV_farmstamatic.swf";
      
      public static const SOUND_URL:String = "assets/sounds/actions/sfx_camera.mp3";
      
      public static const SOUND_ID:String = "camera";
      
      public static const FILTER_IMAGE_PATH_WARM:String = "assets/ugc/farmstamatic/warm.png";
      
      public static const FILTER_IMAGE_PATH_GOLDEN:String = "assets/ugc/farmstamatic/golden.png";
      
      public static const FILTER_IMAGE_PATH_COOL:String = "assets/ugc/farmstamatic/cool.png";
      
      public static const FILTER_IMAGE_PATH_VIGNETTE:String = "assets/ugc/farmstamatic/vignette.png";
      
      protected var m_mainAsset:MovieClip = null;
      
      protected var m_frame:MovieClip = null;
      
      protected var m_whatisthis:FarmAnimatedButton = null;
      
      protected var m_tutorial:MovieClip = null;
      
      protected var m_takePhoto:FarmAnimatedButton = null;
      
      protected var m_imageHolder:MovieClip = null;
      
      protected var close_bt:FarmButton = null;
      
      protected var m_background:MovieClip = null;
      
      protected var m_filterHolder:MovieClip = null;
      
      protected var filterBlendMode:String = "normal";
      
      protected var m_ZoomIn:FarmAnimatedButton = null;
      
      protected var m_ZoomOut:FarmAnimatedButton = null;
      
      protected var m_gameMode:GameMode = null;
      
      protected var m_effect:MovieClip = null;
      
      protected var m_accept:FarmAnimatedButton = null;
      
      protected var m_arrow:MovieClip = null;
      
      protected var m_currentFilter:int = 0;
      
      protected var m_featureComponent:IFarmstamaticFeatureComponent;
      
      public function FarmstamaticTakePhoto(gameMode:GameMode, featureComponent:IFarmstamaticFeatureComponent = null, dialogUrl:String = null)
      {
         super();
         SoundManager.addSound(SOUND_ID,Global.getAssetURL(SOUND_URL),false);
         if(!dialogUrl)
         {
            dialogUrl = ASSET_URL;
         }
         LoadingManager.load(Global.getAssetURL(dialogUrl),this.onLoadComplete,LoadingManager.PRIORITY_HIGH);
         this.m_gameMode = gameMode;
         this.m_featureComponent = featureComponent;
         this.setHUDVisible(false);
      }
      
      protected function setHUDVisible(visible:Boolean) : void
      {
         Global.hud.visible = Global.ui.visible = visible;
         ToasterManager.getInstance().togglePause(!visible);
         IdleTaskQueue.getInstance().togglePause(!visible);
      }
      
      protected function onLoadComplete(event:Event) : void
      {
         this.m_mainAsset = event.target.content;
         this.mouseEnabled = false;
         this.m_frame = this.m_mainAsset.frame_mc as MovieClip;
         this.m_frame.visible = true;
         this.m_frame.mouseEnabled = false;
         this.m_frame.mouseChildren = false;
         this.m_whatisthis = new FarmAnimatedButton(this.m_mainAsset.whatisthis_mc,this.onWhatIsThisClick);
         this.m_whatisthis.visible = true;
         this.m_tutorial = this.m_mainAsset.tutorial_mc as MovieClip;
         this.m_tutorial.visible = false;
         this.m_imageHolder = this.m_mainAsset.imageHolder_mc as MovieClip;
         this.m_imageHolder.mouseEnabled = false;
         this.m_imageHolder.visible = true;
         this.m_imageHolder.mouseChildren = false;
         this.m_effect = this.m_mainAsset.effect_mc as MovieClip;
         this.m_filterHolder = this.m_mainAsset.filterHolder_mc;
         this.m_filterHolder = this.m_mainAsset.filterHolder_mc;
         this.m_takePhoto = new FarmAnimatedButton(this.m_mainAsset.takePhoto_bt,this.onTakePhotoClick);
         this.close_bt = new FarmButton(this.m_mainAsset.close_bt,this.onExitClick);
         this.close_bt.visible = true;
         this.m_arrow = this.m_mainAsset.arrow_mc as MovieClip;
         if(Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMSTAMATIC_EXIT_FLOW)) && !Global.player.getSeenFlag("farmstamatic"))
         {
            this.close_bt.visible = false;
            this.m_arrow.visible = true;
         }
         else
         {
            this.m_arrow.visible = false;
         }
         this.m_background = this.m_mainAsset.bg_mc as MovieClip;
         this.m_background.visible = false;
         for(var i:int = 0; i < 5; i++)
         {
            this.m_mainAsset["filter" + i + "_mc"].filterIndex = i;
            (this.m_mainAsset["filter" + i + "_mc"] as MovieClip).addEventListener(MouseEvent.CLICK,this.onFilterClick);
         }
         this.m_ZoomIn = new FarmAnimatedButton(this.m_mainAsset.zoomIn_bt,UI.onZoomInClick);
         this.m_ZoomIn.visible = true;
         this.m_ZoomOut = new FarmAnimatedButton(this.m_mainAsset.zoomOut_bt,UI.onZoomOutClick);
         this.m_ZoomOut.visible = true;
         addChild(this.m_mainAsset);
         this.x = Global.stage.stageWidth / 2 - this.m_background.width / 2;
         this.y = Global.stage.stageHeight / 2 - this.m_background.height / 2;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMSTAMATIC_AUTO_FILTER))
         {
            this.applyFilter(Math.floor(Math.random() * 4 + 1));
         }
         StatsManager.count("camera","viewer","dialog","view");
      }
      
      public function onFilterClick(event:MouseEvent) : void
      {
         this.applyFilter(event.currentTarget.filterIndex);
      }
      
      public function applyFilter(filterIndex:int) : void
      {
         this.clearFilterHolder();
         this.m_currentFilter = filterIndex;
         var imagePath:String = null;
         switch(filterIndex)
         {
            case 1:
               imagePath = FILTER_IMAGE_PATH_WARM;
               this.filterBlendMode = BlendMode.OVERLAY;
               break;
            case 2:
               imagePath = FILTER_IMAGE_PATH_GOLDEN;
               this.filterBlendMode = BlendMode.OVERLAY;
               break;
            case 3:
               imagePath = FILTER_IMAGE_PATH_COOL;
               this.filterBlendMode = BlendMode.OVERLAY;
               break;
            case 4:
               imagePath = FILTER_IMAGE_PATH_VIGNETTE;
               this.filterBlendMode = BlendMode.OVERLAY;
         }
         if(imagePath)
         {
            LoadingManager.load(Global.getAssetURL(imagePath),this.onFilterLoaded,LoadingManager.PRIORITY_HIGH);
         }
      }
      
      public function onFilterLoaded(event:Event) : void
      {
         var filter:DisplayObject = event.target.content as DisplayObject;
         if(filter)
         {
            this.m_filterHolder.addChild(filter);
            this.m_filterHolder.blendMode = this.filterBlendMode;
            this.m_filterHolder.mouseEnabled = false;
         }
      }
      
      public function onTakePhotoClick(event:MouseEvent) : void
      {
         StatsManager.count("camera","viewer","save_photo","click",this.m_currentFilter.toString());
         this.m_imageHolder.visible = false;
         this.m_arrow.visible = false;
         this.m_takePhoto.enabled = false;
         SoundManager.playSound(SOUND_ID);
         var photo:FarmstamaticPhoto = new FarmstamaticPhoto();
         photo.setBitmapData(this.getSnapshot());
         this.m_imageHolder.visible = true;
         this.m_effect.visible = true;
         this.m_effect.gotoAndPlay(0);
         this.m_effect.gotoAndPlay(0);
         FarmstamaticManager.sendSnapshot(photo.getBitmapData(),this.onPhotoSaved,this.m_featureComponent);
      }
      
      public function onWhatIsThisClick(event:MouseEvent) : void
      {
         StatsManager.count("camera","viewer","help_button","click");
         this.m_tutorial.visible = true;
         this.m_tutorial.gotoAndPlay(2);
         this.m_takePhoto.enabled = false;
         this.m_filterHolder.mouseEnabled = false;
         this.m_ZoomIn.enabled = false;
         this.m_ZoomOut.enabled = false;
         this.m_accept = new FarmAnimatedButton(this.m_tutorial.accept_bt,this.onAcceptTutorial) as FarmAnimatedButton;
      }
      
      public function onAcceptTutorial(event:MouseEvent) : void
      {
         this.m_tutorial.visible = false;
         this.m_takePhoto.enabled = true;
         this.m_filterHolder.mouseEnabled = true;
         this.m_ZoomIn.enabled = true;
         this.m_ZoomOut.enabled = true;
      }
      
      public function onPhotoSaved(result:Object) : void
      {
         var message:String = "";
         if(result.hasOwnProperty("imagePath"))
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("sharePhotoResponseHandler",this.sharePhotoResponseHandler);
               ExternalUtil.instance.call("FarmNS.Request2Manager.shareFarmstamaticPhoto",result["imagePath"],message);
            }
         }
         else
         {
            StatsManager.count("camera","errors","save_failed");
            if(this.m_takePhoto)
            {
               this.m_takePhoto.enabled = true;
            }
         }
         if(this.m_featureComponent)
         {
            this.m_featureComponent.onSubmitPhotoResult(result);
         }
         Global.player.setSeenFlag("farmstamatic");
      }
      
      public function sharePhotoResponseHandler(response:Object) : void
      {
         this.close_bt.visible = true;
         ToasterManager.getInstance().togglePause(false);
         if(response == null || response.hasOwnProperty("error"))
         {
            StatsManager.count("camera","errors","share_failed");
            ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow("Save Failed",null,new Point(0,0)));
         }
         else
         {
            StatsManager.count("camera","share","success");
         }
         if(this.m_takePhoto)
         {
            this.m_takePhoto.enabled = true;
         }
         if(this.m_effect)
         {
            this.m_effect.stop();
            this.m_effect.visible = false;
         }
      }
      
      public function onExitClick(event:MouseEvent) : void
      {
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         if(Global.world.getTopGameMode() is GMFarmstamatic)
         {
            Global.world.getTopGameMode().disableMode();
            Global.world.addGameMode(new GMDefault());
         }
         this.m_mainAsset = null;
         this.m_frame = null;
         this.m_imageHolder = null;
         this.m_filterHolder = null;
         this.m_ZoomIn = null;
         this.m_ZoomOut = null;
         this.m_tutorial = null;
         this.m_whatisthis = null;
         this.m_effect = null;
         this.m_background = null;
         this.m_gameMode = null;
         this.m_takePhoto = null;
         this.setHUDVisible(true);
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function getSnapshot() : BitmapData
      {
         var stageBitmapData:BitmapData = new BitmapData(Global.stage.stageWidth,Global.stage.stageHeight,true,0);
         var bitmapMatrix:Matrix = new Matrix();
         stageBitmapData.draw(Global.stage,bitmapMatrix,null,null,null,true);
         var sourceRect:Rectangle = new Rectangle(stageBitmapData.width / 2 - PHOTO_SIZE_X / 2 + 10,stageBitmapData.height / 2 - PHOTO_SIZE_Y / 2 + 10,PHOTO_SIZE_X,PHOTO_SIZE_Y);
         var bitmapData:BitmapData = new BitmapData(PHOTO_SIZE_X,PHOTO_SIZE_Y,false,0);
         bitmapData.copyPixels(stageBitmapData,sourceRect,new Point(0,0));
         return bitmapData;
      }
      
      private function clearFilterHolder() : void
      {
         while(this.m_filterHolder.numChildren > 0)
         {
            this.m_filterHolder.removeChildAt(0);
         }
      }
   }
}

