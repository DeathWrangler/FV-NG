package Classes
{
   import Engine.Classes.Observer.IObserver;
   import Engine.Classes.World;
   import Engine.Helpers.Vector3;
   import Managers.CaptureFeatureManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class CaptureFeatureItem extends NonCollidableMapResource implements IObserver
   {
      
      private static const FRAME_LABEL_IDLE:String = "IDLE";
      
      private static const FRAME_LABEL_EXIT:String = "Exit Stage";
      
      protected static var DEFAULT_ARROW_SIZE_X:Number = 40.05;
      
      protected static var DEFAULT_ARROW_SIZE_Y:Number = 50.3;
      
      private static const ARROW_ICON:String = "assets/crafting_cottages/Craft_Indicator_Time.png";
      
      private static const ARROW_XOFFSET:int = -35;
      
      private static const ARROW_YOFFSET:int = -150;
      
      private static const FEATURE_ITEM_STATE_IDLE:String = "idle";
      
      private static const FEATURE_ITEM_STATE_CLOSING:String = "closing";
      
      private static const FEATURE_ITEM_STATE_GONE:String = "gone";
      
      private static const SHOW_POPUP_SECONDS_FROM_END_TIME:int = 45;
      
      private static const CLOSING_DURATION:int = 10;
      
      public static const FEATURE_STATE_APPEARED:String = "FeatureState_Appeared";
      
      public static const FEATURE_STATE_INTERACTED:String = "FeatureState_Interacted";
      
      public static const FEATURE_STATE_RESOLVED:String = "FeatureState_Resolved";
      
      private var m_parentResource:HarvestableResource;
      
      private var m_secondsActive:int;
      
      private var m_frameScriptsSet:Boolean = false;
      
      private var m_arrow:ArrowIndicatorWindow;
      
      private var m_arrowBitmapData:BitmapData;
      
      private var m_arrowIsAttached:Boolean = false;
      
      private var m_shownIdleWindow:Boolean = false;
      
      private var m_itemAnimationState:String;
      
      private var m_durationShown:Number = 0;
      
      private var m_showPopupFromStartSeconds:int;
      
      private var m_finalState:String = "FeatureState_Appeared";
      
      private var m_featureName:String;
      
      public function CaptureFeatureItem(featureName:String, itemName:String, plot:HarvestableResource = null, secondsActive:int = 0)
      {
         var observedEvents:Vector.<String> = null;
         super(itemName);
         this.m_secondsActive = secondsActive;
         this.m_featureName = featureName;
         this.m_parentResource = plot;
         if(this.m_parentResource)
         {
            this.setPositionFromPlot();
            this.m_showPopupFromStartSeconds = this.m_secondsActive - SHOW_POPUP_SECONDS_FROM_END_TIME;
            observedEvents = new Vector.<String>();
            observedEvents.push(MapResource.OBSERVABLE_EVENT_STATE,MapResource.OBSERVABLE_EVENT_ALPHA,FarmGameObject.OBSERVABLE_EVENT_MOVE,FarmGameObject.OBSERVABLE_EVENT_PLACE);
            this.m_parentResource.addObserver(this,observedEvents);
            observedEvents = new Vector.<String>();
            observedEvents.push(World.OBSERVABLE_EVENT_DETACH);
            Global.world.addObserver(this,observedEvents);
            this.m_arrow = this.generateArrowIndicator();
         }
         this.m_itemAnimationState = FEATURE_ITEM_STATE_IDLE;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      override public function getCurrentImageName() : String
      {
         return "static";
      }
      
      override protected function addContent(sprite:Sprite, content:DisplayObject) : void
      {
         super.addContent(sprite,content);
         this.startAnimation();
      }
      
      private function getFrameNumberFromLabel(mc:MovieClip, label:String) : int
      {
         var frameLabel:FrameLabel = null;
         var frameNumber:int = 0;
         for each(frameLabel in mc.currentLabels)
         {
            if(frameLabel.name == label)
            {
               frameNumber = frameLabel.frame;
               break;
            }
         }
         return frameNumber;
      }
      
      public function notify(event:String, data:Object) : void
      {
         switch(event)
         {
            case FarmGameObject.OBSERVABLE_EVENT_MOVE:
               if(Boolean(data.obj) && data.obj == this.m_parentResource)
               {
                  this.hideAnimation();
               }
               break;
            case FarmGameObject.OBSERVABLE_EVENT_PLACE:
               if(Boolean(data.obj) && data.obj == this.m_parentResource)
               {
                  this.setPositionFromPlot();
                  conditionallyReattach(true);
                  this.startAnimation();
               }
               break;
            case MapResource.OBSERVABLE_EVENT_STATE:
               if(Boolean(data.object) && data.object == this.m_parentResource)
               {
                  if(Boolean(data.state) && data.state == Plot.STATE_GROWN)
                  {
                     this.hideAnimation();
                  }
               }
               break;
            case MapResource.OBSERVABLE_EVENT_ALPHA:
               if(Boolean(data.object) && data.object == this.m_parentResource)
               {
                  if(Boolean(data.alpha) && data.alpha != 1)
                  {
                     this.hideAnimation();
                  }
                  else if(Boolean(data.alpha) && data.alpha == 1)
                  {
                     if(Boolean(data.state) && data.state != Plot.STATE_GROWN)
                     {
                        this.startAnimation();
                     }
                  }
               }
               break;
            case World.OBSERVABLE_EVENT_DETACH:
               if(data == this.m_parentResource)
               {
                  this.hideAnimation();
               }
         }
      }
      
      private function setPositionFromPlot() : void
      {
         var plotPosition:Vector3 = this.m_parentResource.getPositionNoClone();
         setPosition(plotPosition.x - 1,plotPosition.y - 1,plotPosition.z);
      }
      
      private function hideAnimation() : void
      {
         var image:MovieClip = m_content as MovieClip;
         if(image)
         {
            if(this.m_frameScriptsSet)
            {
               this.m_frameScriptsSet = false;
               image.addFrameScript(image.totalFrames - 1,null);
               image.addFrameScript(this.getFrameNumberFromLabel(image,FRAME_LABEL_EXIT) - 1,null);
            }
            image.gotoAndStop(image.totalFrames - 1,image.currentScene.name);
         }
         this.conditionallyRemoveArrow();
         setVisible(false);
      }
      
      private function startAnimation() : void
      {
         var image:MovieClip = null;
         setVisible(true);
         if(this.m_itemAnimationState == FEATURE_ITEM_STATE_IDLE)
         {
            image = m_content as MovieClip;
            if(image)
            {
               if(!this.m_frameScriptsSet)
               {
                  this.m_frameScriptsSet = true;
                  image.addFrameScript(image.totalFrames - 1,this.detach);
                  image.addFrameScript(this.getFrameNumberFromLabel(image,FRAME_LABEL_EXIT) - 1,this.loopIdleAnimation);
               }
               image.gotoAndPlay(0,image.currentScene.name);
            }
         }
      }
      
      private function loopIdleAnimation() : void
      {
         var image:MovieClip = m_content as MovieClip;
         if(Boolean(image) && this.m_itemAnimationState == FEATURE_ITEM_STATE_IDLE)
         {
            image.gotoAndPlay(FRAME_LABEL_IDLE,image.currentScene.name);
         }
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function detach() : void
      {
         this.helpCleanup();
         super.detach();
      }
      
      override public function cleanUp() : void
      {
         this.helpCleanup();
         super.cleanUp();
      }
      
      private function helpCleanup() : void
      {
         if(this.m_parentResource)
         {
            this.m_parentResource.removeObserver(this);
            Global.world.removeObserver(this);
         }
         this.hideAnimation();
         if(this.m_arrow)
         {
            this.m_arrow.close();
         }
      }
      
      override public function onClick() : void
      {
         if(isVisible() && this.m_itemAnimationState == FEATURE_ITEM_STATE_IDLE)
         {
            CaptureFeatureManager.instance.onFeatureInteraction(this.m_featureName,this);
         }
      }
      
      private function generateArrowIndicator() : ArrowIndicatorWindow
      {
         return new ArrowIndicatorWindow(ARROW_ICON,"","",null,false);
      }
      
      override public function onUpdate(delta:Number) : void
      {
         var image:MovieClip = null;
         super.onUpdate(delta);
         if(this.m_secondsActive != 0)
         {
            if(Boolean(!this.m_arrowIsAttached) && Boolean(this.m_arrow) && m_content is MovieClip)
            {
               this.attachArrow();
            }
            this.m_durationShown += delta;
            if(this.m_durationShown > this.m_showPopupFromStartSeconds && !this.m_shownIdleWindow && this.m_finalState == CaptureFeatureItem.FEATURE_STATE_APPEARED && isVisible())
            {
               this.m_shownIdleWindow = true;
               CaptureFeatureManager.instance.onFeatureIdle(this.m_featureName,this);
            }
            else if(this.m_durationShown > this.m_secondsActive && this.m_itemAnimationState == FEATURE_ITEM_STATE_IDLE)
            {
               this.m_itemAnimationState = FEATURE_ITEM_STATE_CLOSING;
               image = m_content as MovieClip;
               if(image)
               {
                  image.gotoAndPlay(this.getFrameNumberFromLabel(image,FRAME_LABEL_EXIT) + 1);
               }
               this.conditionallyRemoveArrow();
               if(this.m_finalState != CaptureFeatureItem.FEATURE_STATE_RESOLVED)
               {
                  if(this.m_finalState == CaptureFeatureItem.FEATURE_STATE_INTERACTED)
                  {
                     CaptureFeatureManager.instance.onFeatureSeen(this.m_featureName,this);
                  }
                  else
                  {
                     CaptureFeatureManager.instance.onFeatureIgnored(this.m_featureName,this);
                  }
               }
            }
            else if(this.m_durationShown > this.m_secondsActive + CLOSING_DURATION && this.m_itemAnimationState == FEATURE_ITEM_STATE_CLOSING)
            {
               this.m_itemAnimationState = FEATURE_ITEM_STATE_GONE;
               this.detach();
            }
         }
      }
      
      private function attachArrow() : void
      {
         var displayObject:Sprite = getDisplayObject() as Sprite;
         if(Boolean(displayObject) && Boolean(this.m_arrow) && this.m_arrow.isLoaded())
         {
            this.m_arrow.visible = true;
            if(!this.m_arrowBitmapData)
            {
               this.m_arrowBitmapData = this.generateHitArea(this.m_arrow);
            }
            displayObject.addChild(this.m_arrow);
            this.setArrowPosition(displayObject);
            this.m_arrowIsAttached = true;
         }
      }
      
      private function conditionallyRemoveArrow() : void
      {
         var displayObject:Sprite = getDisplayObject() as Sprite;
         if(Boolean(displayObject && this.m_arrow) && Boolean(this.m_arrowIsAttached) && displayObject.contains(this.m_arrow))
         {
            displayObject.removeChild(this.m_arrow);
            this.m_arrowIsAttached = false;
         }
      }
      
      private function setArrowPosition(displayObject:DisplayObject) : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         var child:DisplayObject = null;
         var xOff:int = ARROW_XOFFSET;
         var yOff:int = ARROW_YOFFSET;
         if(Boolean(this.m_arrow) && Boolean(displayObject))
         {
            point = new Point();
            spr = displayObject as Sprite;
            this.m_arrow.scaleX = 0.5 / displayObject.scaleX;
            this.m_arrow.scaleY = 0.5 / displayObject.scaleY;
            child = spr.getChildAt(0);
            if(child)
            {
               point.y = -1 * Math.min(this.m_arrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (child.width - Math.min(this.m_arrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               if(point.x != this.m_arrow.x || point.y != this.m_arrow.y)
               {
                  this.m_arrow.y = point.y + yOff;
                  this.m_arrow.x = point.x + xOff;
               }
            }
         }
      }
      
      override protected function resetAnimation() : void
      {
         var image:MovieClip = m_content as MovieClip;
         if(image)
         {
            image.gotoAndStop(FRAME_LABEL_IDLE,image.currentScene.name);
            resetAllChildClips(image);
         }
      }
      
      override public function isPixelInside(pixel:Point) : Boolean
      {
         return isVisible() && this.m_itemAnimationState == FEATURE_ITEM_STATE_IDLE && (Boolean(super.isPixelInside(pixel)) || this.isPixelInsideArrow(pixel));
      }
      
      private function generateHitArea(displayObject:DisplayObject) : BitmapData
      {
         var result:BitmapData = new BitmapData(displayObject.width,displayObject.height,true,0);
         result.draw(displayObject);
         return result;
      }
      
      protected function isPixelInsideArrow(pixel:Point) : Boolean
      {
         var localPixel:Point = null;
         var result:Boolean = false;
         if(Boolean(this.m_arrow && m_displayObject) && Boolean(this.m_arrowBitmapData) && Boolean(pixel))
         {
            localPixel = pixel.subtract(new Point(m_displayObject.x,m_displayObject.y));
            localPixel.x = (localPixel.x - this.m_arrow.x * m_displayObject.scaleX) / this.m_arrow.scaleX / m_displayObject.scaleX;
            localPixel.y = (localPixel.y - this.m_arrow.y * m_displayObject.scaleY) / this.m_arrow.scaleY / m_displayObject.scaleY;
            result = this.m_arrowBitmapData.hitTest(new Point(0,0),128,localPixel);
         }
         return result;
      }
      
      public function setInteractedWith() : void
      {
         this.m_finalState = CaptureFeatureItem.FEATURE_STATE_INTERACTED;
      }
      
      public function setResolved() : void
      {
         this.m_finalState = CaptureFeatureItem.FEATURE_STATE_RESOLVED;
      }
      
      public function getFinalState() : String
      {
         return this.m_finalState;
      }
   }
}

