package Widgets.Slots.UGC
{
   import Classes.UGC.UGCConstants;
   import Classes.ZItem.FarmItem;
   import Events.DynamicObjectEvent;
   import Managers.UGCDecoManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class UGCDecoSalvageSlots extends ZwSlotFrame
   {
      
      private var m_showItemCount:Boolean;
      
      private var m_itemName:String;
      
      private var m_materialMax:int;
      
      public function UGCDecoSalvageSlots(element:DisplayObject, showCount:Boolean = true)
      {
         super(element);
         this.setShowItemCount(showCount);
      }
      
      override public function populate(data:Object) : void
      {
         var farmIcon:FarmIcon = null;
         super.populate(data);
         this.m_itemName = data["name"];
         this.m_materialMax = data["max"];
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName as String);
         if(item)
         {
            if(m_element.icon)
            {
               removeWidget(m_element.icon);
               farmIcon = new FarmIcon(m_element.icon,item.iconUrl);
               farmIcon.setIconSize(50,50);
               addWidget(farmIcon);
            }
            if(m_element.iconBox_mc)
            {
               m_element.iconBox_mc.visible = true;
            }
            if(m_element.itemTitle_tf)
            {
               removeWidget(m_element.itemTitle_tf);
               addWidget(new ZwTextField(m_element.itemTitle_tf,item.friendlyTitle));
            }
            this.setShowItemCount(this.m_showItemCount);
            UGCDecoManager.instance.addEventListener(UGCConstants.EVENT_MATERIAL_COUNT_MODIFIED,this.onMaterialCountModified,false,0,true);
         }
      }
      
      public function setShowItemCount(showCount:Boolean) : void
      {
         var currentCount:int = 0;
         this.m_showItemCount = showCount;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName as String);
         if(item)
         {
            currentCount = UGCDecoManager.instance.getPartCount(item.name);
            if(m_element.count_tf)
            {
               removeWidget(m_element.count_tf);
               if(this.m_showItemCount)
               {
                  addWidget(new ZwTextField(m_element.count_tf,"x" + currentCount));
               }
            }
            if(m_element.progress_mc)
            {
               m_element.progress_mc.visible = this.m_showItemCount;
               m_element.progress_mc.progressTrack_mc.visible = this.m_showItemCount;
               m_element.progress_mc.progressBar_mc.visible = this.m_showItemCount;
               (m_element.progress_mc as MovieClip).gotoAndStop(this.calculateProgressBar(currentCount));
            }
         }
      }
      
      override public function release() : void
      {
         UGCDecoManager.instance.removeEventListener(UGCConstants.EVENT_MATERIAL_COUNT_MODIFIED,this.onMaterialCountModified,false);
         super.release();
      }
      
      private function calculateProgressBar(currentCount:int) : int
      {
         return currentCount / this.m_materialMax * (m_element.progress_mc as MovieClip).totalFrames;
      }
      
      private function onMaterialCountModified(event:DynamicObjectEvent) : void
      {
         var effect:MovieClip = null;
         var data:Object = event["data"];
         if(data)
         {
            if(data["material"] == this.m_itemName && this.m_showItemCount == true)
            {
               if(m_element.progress_mc)
               {
                  (m_element.progress_mc as MovieClip).gotoAndStop(this.calculateProgressBar(data.newAmt));
               }
               if(m_element.count_tf)
               {
                  m_element.count_tf.text = "x" + data.newAmt;
               }
               effect = m_element["effect_mc"] as MovieClip;
               if(effect)
               {
                  effect.visible = true;
                  effect.gotoAndPlay(1);
               }
            }
         }
      }
   }
}

