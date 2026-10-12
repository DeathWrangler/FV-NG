package Display.HUD
{
   import Classes.buffs.BHarvestHelper;
   import Classes.util.ZLocUtils;
   import Display.FarmGameSprite;
   import Engine.Managers.LoadingManager;
   import Widgets.TextFields.FarmTextField;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HarvestHelperHudIcon extends FarmGameSprite
   {
      
      private static const ASSET_PATH:String = "assets/hud/hud_icon_queue/FV_HarvestHelper2014_HUD.swf";
      
      private static const TWEEN_DURATION:Number = 2;
      
      private var m_hudAsset:MovieClip = null;
      
      private var m_playAnimation:Boolean;
      
      private var m_animationStartX:Number;
      
      private var m_animationStartY:Number;
      
      private var m_hudX:Number = 0;
      
      private var m_hudY:Number = 0;
      
      private var m_timeLeftText:FarmTextField;
      
      private var m_animationComplete:Boolean = true;
      
      public function HarvestHelperHudIcon(playAnimation:Boolean, animationStartX:Number = 0, animationStartY:Number = 0)
      {
         this.m_playAnimation = playAnimation;
         this.m_animationStartX = animationStartX;
         this.m_animationStartY = animationStartY;
         super();
         LoadingManager.load(Global.getAssetURL(ASSET_PATH),this.onAssetLoaded,LoadingManager.PRIORITY_HIGH);
      }
      
      public function adjustPosition(x:int, y:int) : void
      {
         if(this.m_hudAsset)
         {
            this.m_hudX = x - this.m_hudAsset.width - 30;
            this.m_hudY = y - 20;
            this.setPosition(this.m_hudX,this.m_hudY);
         }
      }
      
      public function updateTimeText(text:String) : void
      {
         if(this.m_timeLeftText)
         {
            this.m_timeLeftText.text = text;
         }
      }
      
      private function playTweenAnimation() : void
      {
         var tweenParams:Object = null;
         if(this.m_hudAsset)
         {
            this.m_hudAsset.visible = true;
            this.setPosition(this.m_animationStartX,this.m_animationStartY);
            this.m_animationComplete = false;
            tweenParams = {
               "x":this.m_hudX,
               "y":this.m_hudY,
               "alpha":1,
               "onComplete":this.showTweenComplete
            };
            TweenLite.to(this.m_hudAsset,TWEEN_DURATION,tweenParams);
         }
      }
      
      private function showTweenComplete() : void
      {
         this.m_animationComplete = true;
      }
      
      private function setPosition(x:int, y:int) : void
      {
         if(this.m_animationComplete && Boolean(this.m_hudAsset))
         {
            this.m_hudAsset.x = x;
            this.m_hudAsset.y = y;
         }
      }
      
      public function onAssetLoaded(event:Event) : void
      {
         var toolTipText:String = null;
         this.m_hudAsset = event.target.content as MovieClip;
         if(this.m_hudAsset)
         {
            this.addChild(this.m_hudAsset);
            toolTipText = ZLocUtils.t("Dialogs","Harvest_Helper_Hud_tooltip",{"multiplier":BHarvestHelper.MULTIPLIER_VALUE.toString()});
            this.toolTip = toolTipText;
            if(this.m_hudAsset.hasOwnProperty("generic_tf"))
            {
               this.m_timeLeftText = new FarmTextField(this.m_hudAsset.generic_tf,ZLocUtils.t("Dialogs","Harvest_Helper_Hud_text",{"days":6}));
            }
            Global.hud.lockVisualEffectsForNextUpdate();
            Global.hud.conditionallyRefreshHUD(true);
            if(this.m_playAnimation)
            {
               this.m_hudAsset.visible = false;
               this.playTweenAnimation();
            }
         }
      }
   }
}

