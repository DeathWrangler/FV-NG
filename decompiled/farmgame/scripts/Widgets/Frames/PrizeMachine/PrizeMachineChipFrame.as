package Widgets.Frames.PrizeMachine
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FeatureOptionsManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.PrizeMachine.PrizeMachineChipSlot;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class PrizeMachineChipFrame extends FarmSlotContainerFrame
   {
      
      private static const DEFAULT_PRIZE_NAME:String = "unicorn_milkyway";
      
      private var m_grandPrizeIcon:FarmIcon;
      
      private var m_grandPrizeName:ZwTextField;
      
      private var m_animationEffect:ZwBaseWidget;
      
      public function PrizeMachineChipFrame(element:DisplayObject)
      {
         super(element);
         addWidget(this.m_grandPrizeIcon = new FarmIcon(m_element.prize_mc));
         this.m_grandPrizeIcon.setIconSize(75,75);
         addWidget(this.m_grandPrizeName = new ZwTextField(m_element.prizename_txt));
         addWidget(this.m_animationEffect = new ZwBaseWidget(m_element.effect_mc),false);
         (this.m_animationEffect.element as MovieClip).stop();
         this.displayGrandPrize();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PrizeMachineChipSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "panel_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "";
      }
      
      public function displayGrandPrize() : void
      {
         var grandPrize:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getGrandPrizeName());
         if(grandPrize != null)
         {
            this.m_grandPrizeName.text = ZLocUtils.tk_pk_asTitle(grandPrize.friendlyName);
            this.m_grandPrizeIcon.loadIcon(grandPrize.icon);
         }
      }
      
      public function playCollectionPrizeAnimation() : void
      {
         this.m_animationEffect.visible = true;
         (this.m_animationEffect.element as MovieClip).gotoAndPlay(0);
      }
      
      private function getGrandPrizeName() : String
      {
         var prizeMachineOption:Object = null;
         var runtimeValue:String = null;
         var runtimeConfigs:Array = null;
         var i:int = 0;
         var runtimeTokens:Array = null;
         var startTime:uint = 0;
         var expireTime:uint = 0;
         var serverTime:uint = 0;
         var result:String = null;
         if(!PrizeMachineWindow.isTimedVariant() && FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE) != null)
         {
            prizeMachineOption = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE);
            if(prizeMachineOption.hasOwnProperty("current_game") && prizeMachineOption["current_game"] != null && prizeMachineOption["current_game"] != "")
            {
               result = prizeMachineOption["current_game"];
            }
         }
         else if(Global.flashHotParams["PRIZE_MACHINE_GRAND_PRIZE"] != null || result == null)
         {
            runtimeValue = Global.flashHotParams["PRIZE_MACHINE_GRAND_PRIZE"];
            runtimeConfigs = runtimeValue.split(/,/);
            for(i = 0; i < runtimeConfigs.length; i++)
            {
               runtimeTokens = runtimeConfigs[i].split(/:/);
               if(runtimeTokens.length == 3)
               {
                  startTime = FarmGameUtil.synchronizedDateToNumber(runtimeTokens[1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  expireTime = FarmGameUtil.synchronizedDateToNumber(runtimeTokens[2]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  if(expireTime > serverTime && serverTime > startTime)
                  {
                     result = runtimeTokens[0];
                  }
               }
            }
         }
         if(result == null && Config.DEBUG_MODE)
         {
            UI.displayMessage("Prize Machine - Error retrieving the grand prize for the current user");
            result = DEFAULT_PRIZE_NAME;
         }
         return result;
      }
   }
}

