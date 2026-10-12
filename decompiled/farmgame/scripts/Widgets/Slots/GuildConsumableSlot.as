package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.GuildMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GuildConsumableSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      protected var m_data:Object;
      
      private var m_consumableIcon:FarmIcon;
      
      private var m_hitWidget:ZwWidget;
      
      private var m_readyWidget:ZwWidget;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_timeTextField:ZwTextField;
      
      private var m_progressFrame:ZwFrame;
      
      private var m_progressBar:ZwWidget;
      
      private var m_harvestTimer:Timer;
      
      private var m_actionTooltip:WidgetTooltip;
      
      private var m_screenWidget:ZwWidget;
      
      private var m_featureName:String;
      
      private var m_consumableFarmItem:FarmItem;
      
      private var m_index:int;
      
      private var m_hover_mc:MovieClip;
      
      private var m_collectButton:FarmAnimatedTextButton;
      
      private var m_countTf:ZwTextField;
      
      public function GuildConsumableSlot(element:DisplayObject, featureName:String = "")
      {
         super(element);
         this.m_featureName = featureName;
         addWidget(this.m_consumableIcon = new FarmIcon(m_element.icon_mc));
         this.m_consumableIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_consumableIcon.setSmoothing(true);
         this.m_consumableIcon.visible = true;
         this.m_readyWidget = addWidget(new ZwWidget(m_element.ready_mc),false) as ZwWidget;
         this.m_readyWidget.visible = true;
         if(m_element.hit_area_mc)
         {
            this.m_hitWidget = addWidget(new ZwWidget(m_element.hit_area_mc)) as ZwWidget;
            (this.m_hitWidget.element as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hitWidget.element as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         var tooltipFrame:ZwFrame = new ZwFrame(m_element.tooltip_mc) as ZwFrame;
         this.m_nameTextField = tooltipFrame.addWidget(new ZwTextField(m_element.hover_mc.header_tf," ")) as ZwTextField;
         this.m_timeTextField = tooltipFrame.addWidget(new ZwTextField(m_element.hover_mc.subheader_tf," ")) as ZwTextField;
         this.m_progressFrame = addWidget(new ZwFrame(m_element.progressBar_mc)) as ZwFrame;
         this.m_progressBar = this.m_progressFrame.addWidget(new ZwWidget(m_element.progressBar_mc.bar_mc)) as ZwWidget;
         this.m_hover_mc = m_element["hover_mc"] as MovieClip;
         this.m_hover_mc.visible = false;
         if(m_element.hasOwnProperty("collect_bt"))
         {
            this.m_collectButton = new FarmAnimatedTextButton(m_element["collect_bt"],"Harvest");
            this.m_collectButton.visible = true;
         }
         if(m_element.hasOwnProperty("count_tf"))
         {
            this.m_countTf = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
         }
      }
      
      override public function release() : void
      {
         if(this.m_hitWidget)
         {
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         this.m_hitWidget = null;
         this.m_readyWidget = null;
         this.m_nameTextField = null;
         this.m_timeTextField = null;
         this.m_progressBar = null;
         this.m_progressFrame = null;
         this.m_actionTooltip = null;
         if(this.m_harvestTimer)
         {
            this.m_harvestTimer.removeEventListener(TimerEvent.TIMER,this.onHarvestTimer);
            this.m_harvestTimer.stop();
            this.m_harvestTimer = null;
         }
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_consumableFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.code);
            this.m_index = this.m_data.index;
            this.m_consumableIcon.loadIcon(this.m_consumableFarmItem.iconUrl);
            this.m_consumableIcon.visible = true;
            this.m_readyWidget.visible = true;
            this.m_countTf.text = FeatureOptionsInventoryManager.getInstance().getCount(this.m_data.code).toString();
            this.m_countTf.visible = true;
         }
         var timeLeft:int = GuildManager.getInstance().getTimeRemainingToCollectConsumable(this.m_index);
         var timeLeftText:String = FarmGameUtil.toFriendlyTime(timeLeft);
         this.m_timeTextField.text = timeLeftText;
         this.m_timeTextField.visible = timeLeft > 0;
         this.m_nameTextField.text = this.m_consumableFarmItem.friendlyTitle;
         this.m_hitWidget.visible = true;
         var progressPercentage:Number = 1 - timeLeft / GuildManager.THROTTLE_TIME_ARRAY[this.m_index];
         (this.m_progressBar.element as MovieClip).scaleX = Math.max(Math.min(progressPercentage,1),0);
         this.m_progressFrame.visible = true;
         if(!this.m_harvestTimer)
         {
            this.m_harvestTimer = new Timer(1000);
            this.m_harvestTimer.addEventListener(TimerEvent.TIMER,this.onHarvestTimer);
            this.m_harvestTimer.start();
         }
         if(GuildManager.getInstance().canCollectConsuamble(this.m_index))
         {
            this.m_collectButton.visible = true;
            this.m_collectButton.callback = null;
            this.m_collectButton.callback = this.onCollectClick;
            this.m_readyWidget.visible = true;
         }
         else
         {
            this.m_collectButton.callback = null;
            this.m_collectButton.visible = false;
            this.m_readyWidget.visible = false;
         }
      }
      
      private function onHarvestTimer(event:TimerEvent) : void
      {
         var timeLeft:int = GuildManager.getInstance().getTimeRemainingToCollectConsumable(this.m_index);
         var timeLeftText:String = FarmGameUtil.toFriendlyTime(timeLeft);
         this.m_timeTextField.text = timeLeftText;
         if(Boolean(this.manager.m_guildMainWindow) && Boolean(this.manager.m_guildMainWindow.m_consumableSlotFrame))
         {
            this.manager.m_guildMainWindow.m_consumableSlotFrame.refresh();
         }
         if(Boolean(this.manager.m_welcomeWindow) && Boolean(this.manager.m_welcomeWindow.m_consumableSlotFrame))
         {
            this.manager.m_welcomeWindow.m_consumableSlotFrame.refresh();
         }
      }
      
      private function onCollectClick(event:MouseEvent) : void
      {
         GuildManager.getInstance().collectConsumable(this.m_index);
         if(GuildMainWindow.m_FTUEState == 5)
         {
            ++GuildMainWindow.m_FTUEState;
            if(this.manager.m_guildMainWindow)
            {
               this.manager.m_guildMainWindow.resumeFTUEFlow();
            }
         }
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance(this.m_featureName);
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         if(this.m_hover_mc)
         {
            this.m_hover_mc.visible = true;
         }
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         if(this.m_hover_mc)
         {
            this.m_hover_mc.visible = false;
         }
      }
   }
}

