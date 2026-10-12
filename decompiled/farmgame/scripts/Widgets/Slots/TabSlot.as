package Widgets.Slots
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwWindowSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TabSlot extends ZwWindowSlotFrame
   {
      
      private var m_featureNameKey:String = "";
      
      private var m_text:String = "";
      
      private var m_callback:Function;
      
      public function TabSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
         this.registerEventListener(MouseEvent.CLICK,this.callHandler);
      }
      
      override public function populate(data:Object) : void
      {
         if(data)
         {
            if(data["featureName"])
            {
               this.m_featureNameKey = data.featureName;
               this.m_text = ZLocUtils.t("Dialogs",this.m_featureNameKey + "_tabName");
            }
            if(data["callback"])
            {
               this.m_callback = data.callback;
            }
         }
         this.deselect();
      }
      
      private function callHandler(event:Event) : void
      {
         this.m_callback(this);
         this.select();
      }
      
      public function deselect() : void
      {
         (m_element as MovieClip).gotoAndStop(2);
         m_element.generic_tf.text = this.m_text;
      }
      
      public function select() : void
      {
         (m_element as MovieClip).gotoAndStop(1);
         m_element.generic_tf.text = this.m_text;
      }
      
      public function get featureNameKey() : String
      {
         return this.m_featureNameKey;
      }
      
      override public function release() : void
      {
         this.m_featureNameKey = null;
         this.m_text = null;
         this.m_callback = null;
         this.unregisterEventListener(MouseEvent.CLICK,this.callHandler);
         super.release();
      }
   }
}

