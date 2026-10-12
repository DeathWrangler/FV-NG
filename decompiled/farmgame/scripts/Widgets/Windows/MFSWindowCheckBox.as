package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class MFSWindowCheckBox extends ZwFrame
   {
      
      private var m_selected:Boolean;
      
      private var m_selectAllTextField:ZwTextField;
      
      private var m_clickCallback:Function;
      
      private var m_checkMark:ZwBaseWidget;
      
      private var m_statsFlowName:String;
      
      public function MFSWindowCheckBox(element:DisplayObject, callBack:Function, statsFlowName:String)
      {
         super(element);
         this.m_clickCallback = callBack;
         this.m_statsFlowName = statsFlowName;
         addWidget(new ZwFrame(m_element as DisplayObject)) as ZwFrame;
         this.m_selectAllTextField = addWidget(new ZwTextField(m_element.selectAll_txt,ZLocUtils.t("Dialogs","MFSWindow_SelectAll"))) as ZwTextField;
         this.m_checkMark = addWidget(new ZwBaseWidget(m_element.mc_checkmark as DisplayObject));
         this.m_checkMark.visible = true;
         this.m_selected = true;
         this.registerEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function get checkSelected() : Boolean
      {
         return this.m_selected;
      }
      
      public function setCheckSelected(selected:Boolean) : void
      {
         this.m_selected = selected;
         this.m_checkMark.visible = selected;
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_selected)
         {
            this.m_selected = false;
            this.m_checkMark.visible = false;
         }
         else
         {
            this.m_selected = true;
            this.m_checkMark.visible = true;
         }
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback();
         }
      }
   }
}

