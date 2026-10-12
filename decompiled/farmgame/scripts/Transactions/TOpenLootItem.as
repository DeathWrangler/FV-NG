package Transactions
{
   import Classes.LootableDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Engine.Managers.LoadingManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class TOpenLootItem extends TWorldState
   {
      
      protected var m_lootItem:LootableDecoration;
      
      protected var m_wonItemName:String = "";
      
      protected var m_popup:GenericPopup;
      
      protected var m_dummy:Number = 0;
      
      protected var m_xpGain:int = -1;
      
      protected var m_params:Object;
      
      protected var m_isGift:Boolean = false;
      
      private var lastFrameTime:Number;
      
      public function TOpenLootItem(lootItem:LootableDecoration, params:Object = null)
      {
         this.m_params = params;
         super(lootItem);
         this.m_lootItem = lootItem;
         this.m_popup = UI.displayMessage(this.m_lootItem.getString("_OpeningBox"),GenericPopup.TYPE_MODAL,null,"",true);
         this.m_isGift = Boolean(this.m_params) && Boolean(this.m_params["isGift"]);
         this.lastFrameTime = -1;
      }
      
      override public function perform() : void
      {
         signedWorldAction("open",this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var itemName:String = null;
         this.m_popup.close();
         if(result)
         {
            if(result.item)
            {
               itemName = result.item.toString();
               if(itemName == null)
               {
               }
               Global.player.addGift(itemName);
               this.m_wonItemName = itemName;
               if(result.xp)
               {
                  this.m_xpGain = result.xp;
               }
               if(this.m_isGift)
               {
                  this.startGiftBoxMCPlaying();
               }
               else
               {
                  TweenLite.to(this,0.2,{
                     "m_dummy":0,
                     "onComplete":this.startMCPlaying
                  });
               }
            }
            else if(result.error)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs",this.m_lootItem.getString(result.error)));
            }
         }
      }
      
      protected function startMCPlaying() : void
      {
         var screen:Vector2 = IsoMath.tilePosToPixelPos(this.m_lootItem.getPosition().x,this.m_lootItem.getPosition().y,this.m_lootItem.getPosition().z);
         var openOverlayUrl:String = this.m_lootItem.getOpenOverlayUrl();
         Global.ui.displayOverlaySWF(Global.getAssetURL(openOverlayUrl),new Point(screen.x,screen.y),null,-100,this.onMCFinishPlaying);
      }
      
      protected function startGiftBoxMCPlaying() : void
      {
         var openOverlayUrl:String = this.m_lootItem.getGiftBoxOverlayUrl();
         var swfLdr:Loader = LoadingManager.load(Global.getAssetURL(openOverlayUrl),this.onLoadOverlaySWF);
      }
      
      private function onLoadOverlaySWF(event:Event) : void
      {
         var overlaySWF_mc:MovieClip = null;
         var overlaySWFLoader:Loader = event.target.loader as Loader;
         if(null != overlaySWFLoader)
         {
            overlaySWF_mc = overlaySWFLoader.content as MovieClip;
            if(overlaySWF_mc)
            {
               overlaySWF_mc.x = Global.hud.width * 0.5 - overlaySWF_mc.loaderInfo.width * 0.5;
               overlaySWF_mc.y = Global.hud.height * 0.5 - overlaySWF_mc.loaderInfo.height * 0.5;
               overlaySWF_mc.addEventListener(Event.ENTER_FRAME,this.checkOverlayCompletion);
               Global.hud.addChild(overlaySWF_mc);
            }
         }
      }
      
      private function checkOverlayCompletion(event:Event) : void
      {
         var timeInterval:Number = NaN;
         var framesToSkip:uint = 0;
         var overlay:MovieClip = event.currentTarget as MovieClip;
         if(this.lastFrameTime == -1)
         {
            this.lastFrameTime = GlobalEngine.currentTime;
         }
         else
         {
            timeInterval = GlobalEngine.currentTime - this.lastFrameTime;
            framesToSkip = uint(timeInterval / 16.6);
            if(framesToSkip > 0)
            {
               overlay.gotoAndStop(overlay.currentFrame + framesToSkip);
               this.lastFrameTime = GlobalEngine.currentTime;
            }
         }
         if(overlay.currentFrame >= overlay.totalFrames)
         {
            this.lastFrameTime = -1;
            overlay.removeEventListener(Event.ENTER_FRAME,this.checkOverlayCompletion);
            overlay.stop();
            if(overlay.parent)
            {
               overlay.parent.removeChild(overlay);
            }
            this.onMCFinishPlaying();
         }
      }
      
      protected function onMCFinishPlaying() : Boolean
      {
         var wonItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_wonItemName);
         this.m_lootItem.displayPostOpenPopup(wonItem,this.updateXP);
         return false;
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         this.m_popup.close();
      }
      
      protected function updateXP(event:Event) : void
      {
         if(this.m_xpGain > 0)
         {
            this.m_xpGain = Global.player.calculateAndAddXp(this.m_xpGain);
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":this.m_xpGain}));
         }
         if(this.m_isGift)
         {
            UI.displayGiftBoxWindow(false);
         }
      }
   }
}

