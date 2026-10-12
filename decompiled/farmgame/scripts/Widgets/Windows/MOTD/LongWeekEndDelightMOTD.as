package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.WeekendDelightManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.WeekendDelightFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LongWeekEndDelightMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public static var selected:Boolean = true;
      
      private var m_counterMC:MovieClip;
      
      private var m_dayReward_mc:FarmIcon;
      
      private var m_dialog:WeekendDelightFrame = null;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_checkBox:FarmAnimatedButton = null;
      
      private var m_share_bt:MovieClip;
      
      public function LongWeekEndDelightMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var currentDayItem:FarmItem = null;
         var itemName:String = null;
         var currentDay:int = 0;
         var itemOfTheDay:FarmItem = null;
         var checkBoxFlow:Boolean = false;
         super.onLoadComplete(event);
         if(this.m_counterMC == null)
         {
            this.m_counterMC = m_window.mainWindow;
            if(ObjectUtil.pathExists(this.m_counterMC,["accept_bt","generic_tf"]))
            {
               if(WeekendDelightManager.getInstance().isItemeCollected(WeekendDelightManager.getInstance().getCurrentDayNumber()))
               {
                  addWidget(new ZwTextField(this.m_counterMC.accept_bt.generic_tf,"Awesome!"));
               }
               else
               {
                  addWidget(new ZwTextField(this.m_counterMC.accept_bt.generic_tf,"Collect"));
               }
            }
            currentDayItem = WeekendDelightManager.getInstance().getItemOfTheDay();
            itemName = currentDayItem.friendlyTitle;
            if(currentDayItem.type == "seed")
            {
               itemName += " Crop";
            }
            if(this.m_counterMC.hasOwnProperty("body1_tf"))
            {
               addWidget(new ZwTextField(this.m_counterMC.body1_tf,ZLocUtils.t("Dialogs","MOTD_LONG_WEEKEND_DELIGHT_BODY1_TEXT",{"giftOfTheDay":itemName})));
            }
            currentDay = WeekendDelightManager.getInstance().getCurrentDayNumber();
            if(this.m_counterMC.hasOwnProperty("body2_tf"))
            {
               if(currentDay < 3)
               {
                  addWidget(new ZwTextField(this.m_counterMC.body2_tf,ZLocUtils.t("Dialogs","MOTD_LONG_WEEKEND_DELIGHT_BODY2_TEXT",{"nextItem":WeekendDelightManager.getInstance().getItemForSlot(WeekendDelightManager.getInstance().getCurrentDayNumber() + 1).friendlyTitle})));
               }
               else
               {
                  addWidget(new ZwTextField(this.m_counterMC.body2_tf,ZLocUtils.t("Dialogs","MOTD_LONG_WEEKEND_DELIGHT_BODY2_TEXT_THANKS")));
               }
            }
            itemOfTheDay = WeekendDelightManager.getInstance().getItemOfTheDay();
            if(ObjectUtil.pathExists(this.m_counterMC,["dayReward_mc"]))
            {
               this.m_dayReward_mc = new FarmIcon(this.m_counterMC.dayReward_mc,itemOfTheDay.iconUrl);
               this.m_dayReward_mc.loadIcon(itemOfTheDay.getImageByName(FarmItem.ICON_FEED));
               this.m_dayReward_mc.setIconSize(FarmIcon.STANDARD_ICON_WIDTH * 3 / 2,FarmIcon.STANDARD_ICON_HEIGHT * 3 / 2);
               addWidget(this.m_dayReward_mc);
            }
            this.m_dialog = new WeekendDelightFrame(this.m_counterMC.slots_mc,this);
            this.m_dialog.setItemData();
            addWidget(this.m_dialog);
            this.m_share_bt = this.m_counterMC.share_bt;
            checkBoxFlow = false;
            if(this.m_share_bt.hasOwnProperty("generic_tf"))
            {
               this.m_checkMark = this.m_share_bt.check_mc as MovieClip;
               this.m_checkMark.mouseEnabled = true;
               this.m_checkMark.visible = LongWeekEndDelightMOTD.selected = true;
               this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
               this.m_checkBox = addWidget(new FarmAnimatedButton(this.m_share_bt.checkBack_mc,this.onClick)) as FarmAnimatedButton;
               if(WeekendDelightManager.getInstance().isItemeCollected(WeekendDelightManager.getInstance().getCurrentDayNumber()))
               {
                  this.m_checkMark.visible = false;
                  this.m_checkBox.visible = false;
               }
               checkBoxFlow = true;
            }
         }
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = LongWeekEndDelightMOTD.selected = !LongWeekEndDelightMOTD.selected;
      }
      
      override protected function release() : void
      {
         super.release();
      }
   }
}

