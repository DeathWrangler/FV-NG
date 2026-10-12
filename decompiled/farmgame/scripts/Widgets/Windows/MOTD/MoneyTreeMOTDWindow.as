package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class MoneyTreeMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const MONEYTREE_HUD:String = "moneytree2018";
      
      private var m_startDate:String = null;
      
      private var m_daysLeft:int = 0;
      
      private var m_saleDuration:int = 10;
      
      public function MoneyTreeMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
         if(Boolean(displayParams) && Boolean(displayParams["startDate"]))
         {
            this.m_startDate = displayParams["startDate"];
         }
         if(Boolean(displayParams) && Boolean(displayParams["duration"]))
         {
            this.m_saleDuration = displayParams["duration"];
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_window.mainWindow.title_tf != null)
         {
            removeWidget(m_window.mainWindow.title_tf);
            addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_MONEYTREE_2018_Title")));
         }
         this.m_daysLeft = this.m_saleDuration - FarmGameUtil.getDaysSinceStartDate(this.m_startDate);
         if(this.m_daysLeft > 0 && this.m_daysLeft <= this.m_saleDuration)
         {
            if(m_window.mainWindow.body2_tf != null)
            {
               removeWidget(m_window.mainWindow.body2_tf);
               addWidget(new ZwTextField(m_window.mainWindow.body2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_MONEYTREE_2018_Text1",{"daysLeft":this.m_daysLeft})));
            }
         }
      }
   }
}

