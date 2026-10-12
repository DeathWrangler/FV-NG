package Display.QueuedIcons
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Managers.SpendometerManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SpendometerQueuedIcon extends DynamicContentQueuedIcon
   {
      
      public static const SPENDOMETER_ICON_NAME:String = "Spendometer";
      
      public static const SPENDOMETER_ICON_TYPE:String = "SpendometerIcon";
      
      private static var hudIcon:SpendometerQueuedIcon = null;
      
      private var m_assetLoaded:Boolean;
      
      public var m_animation:ZwWidget = null;
      
      public var m_icon:FarmIcon = null;
      
      private var m_currentItemCode:String;
      
      private var m_currentProgress:int;
      
      private var m_totalProgressReqForReward:int;
      
      private var m_toolTipTextToShow:String = "Spend & Earn";
      
      public function SpendometerQueuedIcon(xml:XML)
      {
         super(xml);
         this.m_assetLoaded = false;
      }
      
      public static function showHUDIcon() : void
      {
         if(hudIcon == null)
         {
            hudIcon = Global.hud.rightSideIconQueue.addIcon(SPENDOMETER_ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,null,null,false) as SpendometerQueuedIcon;
         }
      }
      
      public static function removeHUDIcon() : void
      {
         if(hudIcon)
         {
            Global.hud.rightSideIconQueue.removeIconByName(SPENDOMETER_ICON_NAME);
            hudIcon = null;
         }
      }
      
      public static function updateHUDIcon(updateCount:int = 0) : void
      {
         if(hudIcon)
         {
            hudIcon.animateOnUpdate(updateCount);
         }
      }
      
      override protected function onButtonIconLoaded(event:Event) : void
      {
         this.m_assetLoaded = true;
         super.onButtonIconLoaded(event);
      }
      
      override protected function injectContent() : void
      {
         var loadedMC:MovieClip = null;
         var currentItem:FarmItem = null;
         var playToFrame:int = 0;
         if(this.m_assetLoaded)
         {
            loadedMC = m_Loader.content as MovieClip;
            this.m_currentItemCode = SpendometerManager.instance.getLastShownItemCode();
            currentItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_currentItemCode);
            this.m_totalProgressReqForReward = SpendometerManager.instance.getTotalCountReqForItemCode(this.m_currentItemCode);
            if(this.m_currentItemCode == SpendometerManager.instance.getActualCurentItemCode())
            {
               this.m_currentProgress = SpendometerManager.instance.getActualCurrentProgressCount();
            }
            else
            {
               this.m_currentProgress = this.m_totalProgressReqForReward;
            }
            this.m_animation = new ZwWidget(loadedMC.imageHolder_mc.loader_mc);
            m_widgetManager.addWidget(this.m_animation);
            playToFrame = int(100 * this.m_currentProgress / this.m_totalProgressReqForReward);
            playToFrame = playToFrame > 100 ? 100 : playToFrame;
            if(playToFrame >= 1)
            {
               (this.m_animation.element as MovieClip).play();
               (this.m_animation.element as MovieClip).addEventListener(Event.ENTER_FRAME,function(e:Event):void
               {
                  if((m_animation.element as MovieClip).currentFrame == int(100 * m_currentProgress / m_totalProgressReqForReward))
                  {
                     (m_animation.element as MovieClip).stop();
                     (m_animation.element as MovieClip).removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  }
               });
            }
            else
            {
               (this.m_animation.element as MovieClip).gotoAndStop(1);
            }
            if(currentItem)
            {
               this.m_icon = new FarmIcon(loadedMC.imageHolder_mc.icon_mc);
               this.m_icon.setIconSize((loadedMC.imageHolder_mc.icon_mc as MovieClip).width,(loadedMC.imageHolder_mc.icon_mc as MovieClip).height);
               m_widgetManager.addWidget(this.m_icon);
               this.m_icon.loadIcon(currentItem.iconUrl);
            }
            if(playToFrame == 100)
            {
               this.m_toolTipTextToShow = "Collect " + ZLocUtils.tk_pk_asTitle(currentItem.friendlyName) + " !";
            }
            else
            {
               this.m_toolTipTextToShow = "Spend " + (this.m_totalProgressReqForReward - this.m_currentProgress) + " Cash more to win " + ZLocUtils.tk_pk_asTitle(currentItem.friendlyName) + ".";
            }
         }
      }
      
      public function animateOnUpdate(updateCount:int = 0) : void
      {
         var playToFrame:int = 0;
         var currentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_currentItemCode);
         if(SpendometerManager.instance.getLastShownItemCode() == this.m_currentItemCode)
         {
            this.m_totalProgressReqForReward = SpendometerManager.instance.getTotalCountReqForItemCode(this.m_currentItemCode);
            if(this.m_currentItemCode == SpendometerManager.instance.getActualCurentItemCode())
            {
               this.m_currentProgress = SpendometerManager.instance.getActualCurrentProgressCount();
            }
            else
            {
               this.m_currentProgress = this.m_totalProgressReqForReward;
            }
            playToFrame = int(100 * this.m_currentProgress / this.m_totalProgressReqForReward);
            playToFrame = playToFrame > 100 ? 100 : playToFrame;
            if(playToFrame >= 1)
            {
               (this.m_animation.element as MovieClip).play();
               (this.m_animation.element as MovieClip).addEventListener(Event.ENTER_FRAME,function(e:Event):void
               {
                  if((m_animation.element as MovieClip).currentFrame == playToFrame)
                  {
                     (m_animation.element as MovieClip).stop();
                     (m_animation.element as MovieClip).removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  }
               });
            }
            else
            {
               (this.m_animation.element as MovieClip).gotoAndStop(1);
            }
            if(playToFrame == 100)
            {
               this.m_toolTipTextToShow = "Collect " + ZLocUtils.tk_pk_asTitle(currentItem.friendlyName) + " !";
            }
            else
            {
               this.m_toolTipTextToShow = "Spend " + (this.m_totalProgressReqForReward - this.m_currentProgress) + " cash more to win " + ZLocUtils.tk_pk_asTitle(currentItem.friendlyName) + ".";
            }
         }
         else
         {
            this.m_currentItemCode = SpendometerManager.instance.getLastShownItemCode();
            this.m_icon.loadIcon(currentItem.iconUrl);
            this.m_totalProgressReqForReward = SpendometerManager.instance.getTotalCountReqForItemCode(this.m_currentItemCode);
            if(this.m_currentItemCode == SpendometerManager.instance.getActualCurentItemCode())
            {
               this.m_currentProgress = SpendometerManager.instance.getActualCurrentProgressCount();
            }
            else
            {
               this.m_currentProgress = this.m_totalProgressReqForReward;
            }
            playToFrame = int(100 * this.m_currentProgress / this.m_totalProgressReqForReward);
            playToFrame = playToFrame > 100 ? 100 : playToFrame;
            if(playToFrame >= 1)
            {
               (this.m_animation.element as MovieClip).gotoAndPlay(1);
               (this.m_animation.element as MovieClip).addEventListener(Event.ENTER_FRAME,function(e:Event):void
               {
                  if((m_animation.element as MovieClip).currentFrame == playToFrame)
                  {
                     (m_animation.element as MovieClip).stop();
                     (m_animation.element as MovieClip).removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  }
               });
            }
            else
            {
               (this.m_animation.element as MovieClip).gotoAndStop(1);
            }
            if(playToFrame == 100)
            {
               this.m_toolTipTextToShow = "Collect " + ZLocUtils.tk_pk_asTitle(currentItem.friendlyName) + " !";
            }
            else
            {
               this.m_toolTipTextToShow = "Spend " + (this.m_totalProgressReqForReward - this.m_currentProgress) + " Cash more to win " + ZLocUtils.tk_pk_asTitle(currentItem.friendlyName) + ".";
            }
         }
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         if(!extraData)
         {
            extraData = {};
         }
         extraData["iconTooltip"] = this.m_toolTipTextToShow;
         super.onRollOver(event);
      }
   }
}

