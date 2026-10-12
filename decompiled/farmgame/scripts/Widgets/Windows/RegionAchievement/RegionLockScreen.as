package Widgets.Windows.RegionAchievement
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class RegionLockScreen extends ZwFrame
   {
      
      private static const TITLE:String = "regionTitle_tf";
      
      private static const BODY:String = "unlockInfo_tf";
      
      private var m_lockTitleTf:ZwTextField;
      
      private var m_lockDiscTf:ZwTextField;
      
      public function RegionLockScreen(element:DisplayObject, data:Object)
      {
         super(element);
         if(m_element.hasOwnProperty(TITLE))
         {
            this.m_lockTitleTf = addWidget(new ZwTextField(m_element[TITLE],data.title),true) as ZwTextField;
         }
         if(m_element.hasOwnProperty(BODY))
         {
            this.m_lockDiscTf = addWidget(new ZwTextField(m_element[BODY],data.body),true) as ZwTextField;
         }
      }
   }
}

