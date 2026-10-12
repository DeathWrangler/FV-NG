package Widgets.Windows
{
   import Managers.AnimalSanctuaryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuarySelectionWindow extends FarmWindow
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
      
      public function AnimalSanctuarySelectionWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Animal Sanctuary!"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Choose an Animal to Save"));
         }
         for(i = 0; i < 4; i++)
         {
            if(m_window.hasOwnProperty(this.m_animal_name_array[i]))
            {
               this.m_animal_mc_array[i] = m_window[this.m_animal_name_array[i]] as MovieClip;
               this.m_animal_mc_array[i].visible = true;
            }
            if(this.m_animal_mc_array[i].hasOwnProperty("checkmark1_mc"))
            {
               this.m_animal_tick_mc_array[i] = this.m_animal_mc_array[i]["checkmark1_mc"] as MovieClip;
               this.m_animal_tick_mc_array[i].visible = false;
            }
            if(m_window.hasOwnProperty(this.m_select_bt_array_name[i]))
            {
               this.m_animal_select_bt_array[i] = new FarmAnimatedTextButton(m_window[this.m_select_bt_array_name[i]],"Select",this.onSelectAnimal(i));
               this.m_animal_select_bt_array[i].visible = true;
            }
         }
         if(m_window.hasOwnProperty("farm_mc"))
         {
            this.m_farm_mc = m_window["farm_mc"] as MovieClip;
            this.m_farm_mc.visible = false;
            for(i = 0; i < 4; i++)
            {
               if(this.m_farm_mc.hasOwnProperty(this.m_farm_name_array[i]))
               {
                  this.m_farm_mc_array[i] = this.m_farm_mc[this.m_farm_name_array[i]] as MovieClip;
                  this.m_farm_mc_array[i].visible = true;
               }
               if(this.m_farm_mc_array[i].hasOwnProperty("tick_mc"))
               {
                  this.m_farm_tick_mc_array[i] = this.m_farm_mc_array[i]["tick_mc"] as MovieClip;
                  this.m_farm_tick_mc_array[i].visible = false;
               }
               if(this.m_farm_mc_array[i].hasOwnProperty("glow_mc"))
               {
                  this.m_farm_glow_mc_array[i] = this.m_farm_mc_array[i]["glow_mc"] as MovieClip;
                  this.m_farm_glow_mc_array[i].visible = false;
               }
               if(!this.manager.isWorldCompleted(i))
               {
                  this.m_farm_mc_array[i].addEventListener(MouseEvent.CLICK,this.onSelectFarm(i));
               }
            }
            if(this.m_farm_mc.hasOwnProperty("body_tf"))
            {
               addWidget(this.m_body_tf = new ZwTextField(this.m_farm_mc["body_tf"],"Do tasks on these farms to earn coupons and provide food, shelter and medicine to save the animals!"));
               this.m_body_tf.visible = true;
            }
            if(this.m_farm_mc.hasOwnProperty("body1_tf"))
            {
               addWidget(this.m_body1_tf = new ZwTextField(this.m_farm_mc["body1_tf"],"Select a farm to start saving the animal!"));
               this.m_body1_tf.visible = true;
            }
            if(this.m_farm_mc.hasOwnProperty("select_bt"))
            {
               addWidget(this.m_select_bt = new FarmAnimatedTextButton(this.m_farm_mc["select_bt"],"Confirm",this.onConfirm));
               this.m_select_bt.enabled = false;
               this.m_select_bt.visible = true;
            }
            if(this.m_farm_mc.hasOwnProperty("cancel_bt"))
            {
               addWidget(this.m_cancel_bt = new FarmAnimatedTextButton(this.m_farm_mc["cancel_bt"],"Cancel",this.onCancelFarm));
               this.m_cancel_bt.visible = true;
            }
            if(this.m_farm_mc.hasOwnProperty("close_bt"))
            {
               this.m_close_bt = this.m_farm_mc["close_bt"];
               this.m_close_bt.visible = false;
            }
            if(this.m_farm_mc.hasOwnProperty("animal_mc"))
            {
               this.m_animal_mc = this.m_farm_mc["animal_mc"] as MovieClip;
               this.m_animal_mc.visible = true;
               if(this.m_animal_mc.hasOwnProperty("name_tf"))
               {
               }
            }
         }
         this.updateWindow();
      }
      
      public function onSelectAnimal(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_farm_mc.visible = true;
            m_animal_mc.gotoAndStop(slotIndex + 1);
            m_animal_mc.visible = true;
            for(var i:* = 0; i < 4; i++)
            {
               if(manager.isWorldCompleted(i))
               {
                  m_farm_tick_mc_array[i].visible = true;
               }
            }
            manager.m_selectedAnimal = slotIndex;
         };
      }
      
      public function updateWindow() : void
      {
         for(var i:int = 0; i < 4; i++)
         {
            if(this.manager.isAnimalCompleted(i))
            {
               this.m_animal_tick_mc_array[i].visible = true;
               this.m_animal_select_bt_array[i].visible = false;
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
      
      private function onConfirm(evt:Event) : void
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
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
      }
   }
}

