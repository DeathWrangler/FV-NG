package Widgets.Windows
{
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryV2SelectionWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      public var m_closeBt:SimpleButton;
      
      private var m_farm_mc:MovieClip;
      
      private var m_animal_mc:MovieClip;
      
      private var m_animal_name_tf:ZwTextField;
      
      private var m_body_tf:ZwTextField;
      
      private var m_body1_tf:ZwTextField;
      
      private var m_close_bt:SimpleButton;
      
      private var m_select_bt:FarmAnimatedTextButton;
      
      private var m_cancel_bt:FarmAnimatedTextButton;
      
      private var m_animal_mc_array:Array = [];
      
      private var m_animal_tick_mc_array:Array = [];
      
      private var m_animal_select_bt_array:Array = [];
      
      private var m_farm_mc_array:Array = [];
      
      private var m_farm_tick_mc_array:Array = [];
      
      private var m_farm_glow_mc_array:Array = [];
      
      private var m_farn_name_tf_array:Array = [];
      
      private var m_farm_name_array:Array = ["farm0_mc","farm1_mc","farm2_mc","farm3_mc"];
      
      private var m_animal_name_array:Array = ["animal0_mc","animal1_mc","animal2_mc","animal3_mc"];
      
      private var m_select_bt_array_name:Array = ["choose0_bt","choose1_bt","choose2_bt","choose3_bt"];
      
      private var m_allAnimalMc:MovieClip;
      
      private var m_allAnimalMcArray:Array = [];
      
      private var animalNameIndex:int = 0;
      
      private var animalCheckmark:int = 1;
      
      private var animalChoose:int = 2;
      
      private var animalFarmNameIndex:int = 3;
      
      public function AnimalSanctuaryV2SelectionWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var animalMcArray:Array = null;
         var animalMc:MovieClip = null;
         var howMc:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Animal Sanctuary!"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Choose an Animal to Save"));
         }
         if(m_window.hasOwnProperty("all_animal_mc"))
         {
            this.m_allAnimalMc = m_window["all_animal_mc"] as MovieClip;
            for(index = 0; index < 4; index++)
            {
               if(this.m_allAnimalMc.hasOwnProperty("animal_info_" + index + "_mc"))
               {
                  animalMcArray = new Array();
                  animalMc = this.m_allAnimalMc["animal_info_" + index + "_mc"];
                  if(animalMc.hasOwnProperty("animal_name_tf"))
                  {
                     animalMcArray[this.animalNameIndex] = new ZwTextField(animalMc["animal_name_tf"],this.manager.VAL_MAIN_ANIMAL_NAME_ARRAY[index]);
                  }
                  if(animalMc.hasOwnProperty("checkmark_mc"))
                  {
                     animalMcArray[this.animalCheckmark] = animalMc["checkmark_mc"] as MovieClip;
                     animalMcArray[this.animalCheckmark].visible = false;
                  }
                  if(animalMc.hasOwnProperty("choose_bt"))
                  {
                     animalMcArray[this.animalChoose] = new FarmAnimatedTextButton(animalMc["choose_bt"],"Choose",this.onSelectAnimal(index));
                  }
                  if(animalMc.hasOwnProperty("farm_name_tf"))
                  {
                     animalMcArray[this.animalFarmNameIndex] = new ZwTextField(animalMc["farm_name_tf"],this.manager.VAL_FARM_NAMES_ARRAY[index]);
                  }
                  this.m_allAnimalMcArray[index] = animalMcArray;
               }
            }
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            howMc = m_window["howDoesThisWork_mc"] as MovieClip;
            howMc.visible = false;
         }
         this.updateWindow();
      }
      
      public function onSelectAnimal(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            for(var i:* = 0; i < 4; i++)
            {
               if(manager.isWorldCompleted(i))
               {
                  m_allAnimalMcArray[i][animalCheckmark].visible = true;
               }
            }
            manager.m_selectedAnimal = slotIndex;
            manager.m_selectedWorld = slotIndex;
            onConfirm();
         };
      }
      
      public function updateWindow() : void
      {
         for(var i:int = 0; i < 4; i++)
         {
            if(this.manager.isAnimalCompleted(i))
            {
               this.m_allAnimalMcArray[i][this.animalCheckmark].visible = true;
               this.m_allAnimalMcArray[i][this.animalChoose].visible = false;
            }
         }
      }
      
      public function onSelectFarm(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            for(var ind:* = 0; ind < 4; ind++)
            {
               if(ind == slotIndex)
               {
                  m_farm_glow_mc_array[slotIndex].visible = true;
               }
               else if(!manager.isWorldCompleted(ind))
               {
                  m_farm_glow_mc_array[ind].visible = false;
                  m_farm_tick_mc_array[ind].visible = false;
               }
            }
            m_select_bt.enabled = true;
            manager.m_selectedWorld = slotIndex;
         };
      }
      
      private function onConfirm() : void
      {
         this.manager.updateSelectedAnimalAndWorld();
         this.manager.selectionWindow.tintWindow();
         this.manager.selectionWindow.enableInput = false;
      }
      
      private function onCancelFarm(evt:Event) : void
      {
         for(var i:int = 0; i < 4; i++)
         {
            this.m_farm_glow_mc_array[i].visible = false;
            if(this.manager.isWorldCompleted(i))
            {
               this.m_farm_tick_mc_array[i].visible = true;
            }
            else
            {
               this.m_farm_tick_mc_array[i].visible = false;
            }
         }
         this.m_select_bt.enabled = false;
         this.manager.m_selectedWorld = 0;
         this.m_farm_mc.visible = false;
      }
      
      public function onAccept(event:Event) : void
      {
         super.close();
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
      }
   }
}

