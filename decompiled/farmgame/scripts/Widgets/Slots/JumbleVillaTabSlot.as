package Widgets.Slots
{
   import Managers.JumbleVillaManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class JumbleVillaTabSlot extends ZwSlotFrame
   {
      
      protected var m_featureName:String = "JumbleVilla";
      
      private var m_bg_mc:MovieClip;
      
      private var m_checkmark_mc:MovieClip;
      
      private var m_level_lock_mc:MovieClip;
      
      private var m_anim_mc:MovieClip;
      
      private var m_state_locked:Boolean;
      
      private var m_state_completed:Boolean;
      
      private var m_state_clicked:Boolean;
      
      private var m_state_focus:Boolean;
      
      private var m_id:int;
      
      private var m_button:FarmAnimatedTextButton;
      
      public function JumbleVillaTabSlot(element:DisplayObject)
      {
         super(element);
         if(element.hasOwnProperty("bg_mc"))
         {
            this.m_bg_mc = element["bg_mc"] as MovieClip;
         }
         if(element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmark_mc = element["checkmark_mc"] as MovieClip;
         }
         if(element.hasOwnProperty("level_lock_mc"))
         {
            this.m_level_lock_mc = element["level_lock_mc"] as MovieClip;
         }
         if(element.hasOwnProperty("anim_mc"))
         {
            this.m_anim_mc = element["anim_mc"] as MovieClip;
         }
         this.m_button = new FarmAnimatedTextButton(element as MovieClip,"Puzzle",this.onClickTabButton);
      }
      
      override public function populate(data:Object) : void
      {
         this.m_id = data.id;
         this.m_state_locked = data.locked;
         this.m_state_completed = data.completed;
         this.m_state_clicked = data.clicked;
         this.m_state_focus = data.focus;
         this.m_button.enabled = !this.m_state_locked;
         this.showState();
      }
      
      public function showState() : void
      {
         element.visible = true;
         if(this.m_bg_mc)
         {
            this.m_bg_mc.visible = true;
            this.m_bg_mc.gotoAndStop(2 - int(this.m_state_clicked));
         }
         if(this.m_checkmark_mc)
         {
            this.m_checkmark_mc.visible = this.m_state_completed;
         }
         if(this.m_level_lock_mc)
         {
            this.m_level_lock_mc.visible = this.m_state_locked;
         }
         if(this.m_anim_mc)
         {
            this.m_anim_mc.visible = this.m_state_focus;
         }
      }
      
      private function onClickTabButton(event:MouseEvent) : void
      {
         this.manager.changeActiveTab(this.m_id);
      }
      
      private function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(this.m_featureName);
      }
   }
}

