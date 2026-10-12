package Widgets.Frames.UGC
{
   import Classes.UGC.UGCConstants;
   import Engine.Managers.StatsManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class UGCFishColorMatrixFrame extends UGCColorMatrixFrame
   {
      
      private var m_editor:UGCFishItemEditorFrame;
      
      public function UGCFishColorMatrixFrame(element:DisplayObject, editor:UGCFishItemEditorFrame)
      {
         this.m_editor = editor;
         super(element);
      }
      
      override protected function setupData() : void
      {
         m_slotData = UGCConstants.COLOR_DATA_FISH;
      }
      
      override public function release() : void
      {
         this.m_editor = null;
         super.release();
      }
      
      override protected function onPageBack(event:Event) : void
      {
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_scroll","","left");
         this.m_editor.disablePaintMode();
         super.onPageBack(event);
      }
      
      override protected function onPageForward(event:Event) : void
      {
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_scroll","","right");
         this.m_editor.disablePaintMode();
         super.onPageForward(event);
      }
   }
}

