package Widgets.Slots
{
   import Managers.DragonBreedingManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.DragonBreedingFamilyTreeFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   
   public class DragonBreedingFamilyTreeSlot extends ZwSlotFrame
   {
      
      public var m_checkmark_mc:MovieClip;
      
      public var m_select_mc:MovieClip;
      
      public var m_icon_mc:FarmIcon;
      
      public var m_box_mc:MovieClip;
      
      public var m_wait_mc:MovieClip;
      
      private const CHECKMARK_ICON:String = "checkmark_mc";
      
      private const SELECT_MC:String = "select_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const BOX_MC:String = "box_mc";
      
      private const WAIT_MC:String = "wait_mc";
      
      private const SLOT_MOUSE_OVER:int = 2;
      
      private const SLOT_MOUSE_OUT:int = 1;
      
      private var m_slots:Array;
      
      private var male:String;
      
      private var female:String;
      
      private var slotIndex:String;
      
      private var m_owner:DragonBreedingFamilyTreeFrame;
      
      private var m_each_slot:DragonBreedingFamilyTreeSlot;
      
      private var m_featureName:String;
      
      public function DragonBreedingFamilyTreeSlot(slotElement:DisplayObject, slots:Array, index:String, owner:DragonBreedingFamilyTreeFrame, featureName:String)
      {
         super(slotElement);
         this.m_slots = slots;
         this.m_owner = owner;
         this.slotIndex = index;
         this.m_featureName = featureName;
         if(m_element.hasOwnProperty(this.CHECKMARK_ICON))
         {
            this.m_checkmark_mc = m_element.checkmark_mc;
            this.m_checkmark_mc.visible = false;
         }
         if(m_element.hasOwnProperty(this.SELECT_MC))
         {
            this.m_select_mc = m_element.select_mc;
            this.m_select_mc.visible = false;
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            this.m_icon_mc = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
            this.m_icon_mc.visible = false;
         }
         if(m_element.hasOwnProperty(this.BOX_MC))
         {
            this.m_box_mc = m_element.box_mc;
            this.m_box_mc.visible = true;
         }
         if(m_element.hasOwnProperty(this.WAIT_MC))
         {
            this.m_wait_mc = m_element[this.WAIT_MC];
            this.m_wait_mc.visible = true;
         }
      }
      
      private function mouseOver(ev:MouseEvent) : void
      {
         var currentTarget:MovieClip = ev.currentTarget as MovieClip;
         currentTarget.gotoAndStop(this.SLOT_MOUSE_OVER);
      }
      
      private function mouseOut(ev:MouseEvent) : void
      {
         var currentTarget:MovieClip = ev.currentTarget as MovieClip;
         currentTarget.gotoAndStop(this.SLOT_MOUSE_OUT);
      }
      
      override public function populate(data:Object) : void
      {
         var iconUrl:String = null;
         var slotInt:String = null;
         var eachSlot:DragonBreedingFamilyTreeSlot = null;
         if(Boolean(data.femaleDragon && data.femaleDragon != "" && data.maleDragon) && Boolean(data.maleDragon != "") && Boolean(data.slotIndex) && data.slotIndex != "")
         {
            this.male = data.maleDragon;
            this.female = data.femaleDragon;
            slotInt = data.slotIndex;
            this.slotIndex = slotInt;
            iconUrl = Global.getAssetURL(DragonBreedingManager.getInstance(this.m_featureName).getImageForOffspring(this.male,this.female,Number(slotInt)));
            if(data.slot)
            {
               eachSlot = data.slot as DragonBreedingFamilyTreeSlot;
               if(DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring)
               {
                  this.enablePreselected();
               }
               eachSlot.registerEventListener(MouseEvent.CLICK,this.enableSelect);
               eachSlot.registerEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
               eachSlot.registerEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
               eachSlot.visible = true;
               if(eachSlot.m_box_mc)
               {
                  eachSlot.m_box_mc.useHandCursor = true;
                  eachSlot.m_box_mc.visible = true;
               }
               if(eachSlot.m_checkmark_mc)
               {
                  eachSlot.m_checkmark_mc.visible = DragonBreedingManager.getInstance(this.m_featureName).isDragonCollected(data.maleDragon,data.femaleDragon,Number(slotInt));
               }
               if(!(iconUrl != "" || iconUrl != null))
               {
                  throw new Error("Check images for " + this.male + " and " + this.female + "index = " + data.slotIndex);
               }
               if(eachSlot.m_icon_mc)
               {
                  eachSlot.m_wait_mc.visible = true;
                  removeWidget(eachSlot.m_icon_mc);
                  eachSlot.m_icon_mc = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
                  this.m_each_slot = eachSlot;
                  eachSlot.m_icon_mc.loadIcon(iconUrl,this.onHideWait);
                  eachSlot.m_icon_mc.visible = true;
               }
               if(Boolean(data.locked) || Boolean(data.away_breeding))
               {
                  eachSlot.alpha = DragonBreedingManager.GRAY_OUT;
                  this.desaturate(m_element.icon_mc as MovieClip);
                  eachSlot.enabled = false;
               }
               else
               {
                  eachSlot.alpha = DragonBreedingManager.NORMAL;
                  this.resetColor(m_element.icon_mc as MovieClip);
                  eachSlot.enabled = true;
               }
            }
         }
      }
      
      private function onHideWait() : void
      {
         this.m_each_slot.m_wait_mc.visible = false;
      }
      
      private function resetColor(obj:DisplayObject) : void
      {
         obj.filters = [];
      }
      
      private function desaturate(obj:DisplayObject) : void
      {
         var r:Number = 0.212671;
         var g:Number = 0.71516;
         var b:Number = 0.072169;
         var matrix:Array = [r,g,b,0,0,r,g,b,0,0,r,g,b,0,0,0,0,0,1,0];
         obj.filters = [new ColorMatrixFilter(matrix)];
      }
      
      private function enablePreselected() : void
      {
         var getSlot:int = 0;
         var slot:DragonBreedingFamilyTreeSlot = null;
         getSlot = parseInt(DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring.index,10);
         for each(slot in this.m_slots)
         {
            if(slot.m_select_mc)
            {
               slot.m_select_mc.visible = false;
            }
         }
         if(Boolean(this.m_slots[getSlot - 1]) && Boolean(this.m_slots[getSlot - 1].m_select_mc))
         {
            this.m_slots[getSlot - 1].m_select_mc.visible = true;
         }
      }
      
      private function enableSelect(ev:Event) : void
      {
         var getSlot:int = 0;
         var selectedDragon:Object = null;
         var slot:DragonBreedingFamilyTreeSlot = null;
         getSlot = parseInt(this.slotIndex,10);
         DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring = {
            "male":this.male,
            "female":this.female,
            "index":getSlot.toString()
         };
         if(Boolean(this.m_owner.m_selectOutcomeButton) && DragonBreedingManager.getInstance(this.m_featureName).findFreeSlot() >= 0)
         {
            this.m_owner.m_selectOutcomeButton.enabled = true;
         }
         if(this.m_slots[getSlot - 1].m_select_mc.visible)
         {
            this.m_slots[getSlot - 1].m_select_mc.visible = false;
            DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring = null;
            if(this.m_owner.m_selectOutcomeButton)
            {
               this.m_owner.m_selectOutcomeButton.enabled = false;
            }
         }
         else
         {
            for each(slot in this.m_slots)
            {
               if(slot.m_select_mc)
               {
                  slot.m_select_mc.visible = false;
               }
            }
            if(Boolean(this.m_slots[getSlot - 1]) && Boolean(this.m_slots[getSlot - 1].m_select_mc))
            {
               this.m_slots[getSlot - 1].m_select_mc.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_checkmark_mc = null;
         this.m_icon_mc = null;
         this.m_select_mc = null;
      }
   }
}

