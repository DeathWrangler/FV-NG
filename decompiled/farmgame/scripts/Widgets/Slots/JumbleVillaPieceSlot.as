package Widgets.Slots
{
   import Managers.JumbleVillaManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class JumbleVillaPieceSlot extends ZwSlotFrame
   {
      
      protected var m_featureName:String = "JumbleVilla";
      
      private var m_count_tf:ZwTextField;
      
      private var m_dooberCount_tf:ZwTextField;
      
      private var m_anim_mc:MovieClip;
      
      private var m_anim1_mc:MovieClip;
      
      private var m_dooberIcon_mc:MovieClip;
      
      private var m_progress:Number;
      
      private var m_collected:Number;
      
      private var m_required:Number;
      
      private var m_state_visible:Boolean;
      
      private var m_tooltip_mc:ZwFrame;
      
      public function JumbleVillaPieceSlot(element:DisplayObject)
      {
         super(element);
         if(element.hasOwnProperty("count_tf"))
         {
            this.m_count_tf = new ZwTextField(element["count_tf"]);
            this.m_count_tf.visible = false;
         }
         if(element.hasOwnProperty("anim_mc"))
         {
            this.m_anim_mc = element["anim_mc"] as MovieClip;
            this.m_anim_mc.visible = false;
            if(this.m_anim_mc.hasOwnProperty("anim1_mc"))
            {
               this.m_anim1_mc = this.m_anim_mc["anim1_mc"] as MovieClip;
               this.m_anim1_mc.visible = false;
            }
            if(this.m_anim_mc.hasOwnProperty("dooberIcon_mc"))
            {
               this.m_dooberIcon_mc = this.m_anim_mc["dooberIcon_mc"] as MovieClip;
               this.m_dooberIcon_mc.visible = false;
               if(this.m_dooberIcon_mc.hasOwnProperty("dooberCount_tf"))
               {
                  this.m_dooberCount_tf = new ZwTextField(this.m_dooberIcon_mc["dooberCount_tf"]);
                  this.m_dooberCount_tf.visible = false;
               }
            }
         }
         this.m_tooltip_mc = new ZwFrame(element);
      }
      
      override public function populate(data:Object) : void
      {
         this.m_state_visible = data.visible;
         this.m_progress = data.progress;
         this.m_collected = data.collected;
         this.m_required = data.required;
         this.m_count_tf.text = String(this.m_collected) + "/" + String(this.m_required);
         this.showState();
      }
      
      public function showState() : void
      {
         element.visible = this.m_state_visible;
         this.m_count_tf.visible = true;
         if(this.m_progress > 0)
         {
            this.playProgressDoober(this.m_progress);
         }
         if(this.m_collected >= this.m_required)
         {
            element.visible = false;
         }
         this.m_tooltip_mc.detachTooltip();
         this.m_tooltip_mc.visible = false;
         if(this.manager.isFeatureinActivePeriod() && this.m_collected < this.m_required)
         {
            this.m_tooltip_mc.visible = true;
            this.m_tooltip_mc.attachTooltip(new FarmTextTooltip("Find the remaining pieces and complete the picture!"));
         }
      }
      
      private function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(this.m_featureName);
      }
      
      private function playProgressDoober(progress:Number) : void
      {
         if(this.m_anim_mc)
         {
            this.m_anim_mc.visible = true;
            if(this.m_anim1_mc)
            {
               this.m_anim1_mc.visible = true;
            }
            if(this.m_dooberIcon_mc)
            {
               this.m_dooberIcon_mc.visible = true;
            }
            if(this.m_dooberCount_tf)
            {
               this.m_dooberCount_tf.text = "+" + String(progress);
               this.m_dooberCount_tf.visible = true;
            }
            this.m_anim_mc.gotoAndPlay(1);
            this.m_anim_mc.addEventListener(Event.ENTER_FRAME,this.onDooberPlayed);
         }
      }
      
      private function onDooberPlayed(event:Event) : void
      {
         if(this.m_anim_mc)
         {
            if(this.m_anim_mc.currentFrame == 31)
            {
               this.m_anim_mc.gotoAndStop(1);
               this.m_anim_mc.visible = false;
               if(this.m_anim1_mc)
               {
                  this.m_anim_mc.visible = false;
               }
               if(this.m_dooberIcon_mc)
               {
                  this.m_dooberIcon_mc.visible = false;
               }
               if(this.m_dooberCount_tf)
               {
                  this.m_dooberCount_tf.visible = false;
               }
               this.updatePieceProgress();
               this.m_anim_mc.removeEventListener(Event.ENTER_FRAME,this.onDooberPlayed);
            }
         }
      }
      
      private function updatePieceProgress() : void
      {
         if(this.m_count_tf)
         {
            this.m_collected += this.m_progress;
            this.m_progress = 0;
            this.m_count_tf.text = String(this.m_collected) + "/" + String(this.m_required);
            if(this.m_collected >= this.m_required)
            {
               element.visible = false;
            }
         }
      }
   }
}

