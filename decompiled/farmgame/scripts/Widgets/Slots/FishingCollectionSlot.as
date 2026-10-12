package Widgets.Slots
{
   import Managers.FishingV2Manager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FishingCollectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FishingCollectionSlot extends ZwSlotFrame
   {
      
      private var m_index:int;
      
      private var m_mastery_star_mc:MovieClip;
      
      private var m_collectionType:int;
      
      private var m_fish_count_tf:ZwTextField;
      
      private var m_parentWindow:FishingCollectionWindow;
      
      private var m_check_mark_mc:MovieClip;
      
      private var m_fishHitAreaMc:ZwFrame;
      
      public function FishingCollectionSlot(element:DisplayObject, featureName:String, collectionType:int, parentWindow:FishingCollectionWindow)
      {
         super(element);
         this.m_collectionType = collectionType;
         this.m_parentWindow = parentWindow;
         if(m_element.hasOwnProperty("mastery_star_mc"))
         {
            this.m_mastery_star_mc = m_element["mastery_star_mc"] as MovieClip;
         }
         if(m_element.hasOwnProperty("star_outline_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.star_outline_mc));
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_check_mark_mc = m_element["checkmark_mc"] as MovieClip;
            this.m_check_mark_mc.visible = FishingV2Manager.getInstance().hasMasteredFish(this.m_collectionType,this.m_index);
         }
         if(m_element.hasOwnProperty("fish_hit_area_mc"))
         {
            this.m_fishHitAreaMc = new ZwFrame(m_element["fish_hit_area_mc"]) as ZwFrame;
            this.m_fishHitAreaMc.visible = true;
            if(FishingV2Manager.getInstance().hasMasteredFish(this.m_collectionType,this.m_index))
            {
               this.m_fishHitAreaMc.attachTooltip(new FarmTextTooltip("You have mastered this fish!"));
            }
            else
            {
               this.m_fishHitAreaMc.attachTooltip(new FarmTextTooltip("Complete fish mastery to get this fish as reward!"));
            }
         }
         if(m_element.hasOwnProperty("count_tf"))
         {
            addWidget(this.m_fish_count_tf = new ZwTextField(m_element["count_tf"],""));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var levelMC:MovieClip = null;
         super.populate(data);
         this.m_index = data.index;
         this.m_fish_count_tf.visible = true;
         this.m_fish_count_tf.text = FishingV2Manager.getInstance().getfishCount(this.m_collectionType,this.m_index).toString() + "/9";
         if(this.m_check_mark_mc)
         {
            this.m_check_mark_mc.visible = FishingV2Manager.getInstance().hasMasteredFish(this.m_collectionType,this.m_index);
         }
         this.m_fish_count_tf.visible = !FishingV2Manager.getInstance().hasMasteredFish(this.m_collectionType,this.m_index);
         this.m_mastery_star_mc.visible = true;
         var index:int = 0;
         while(this.m_mastery_star_mc.hasOwnProperty("level_star" + index.toString() + "_mc"))
         {
            levelMC = this.m_mastery_star_mc["level_star" + index.toString() + "_mc"] as MovieClip;
            levelMC.visible = index < FishingV2Manager.getInstance().getMasteryStarsCount(this.m_collectionType,this.m_index);
            index++;
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

