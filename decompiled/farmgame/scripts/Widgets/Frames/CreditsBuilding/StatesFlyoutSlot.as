package Widgets.Frames.CreditsBuilding
{
   import Classes.CreditsBuilding;
   import Classes.RewardCreditsBuilding;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class StatesFlyoutSlot extends ZwSlotFrame
   {
      
      protected static const ICON_SIZE:int = 65;
      
      private var m_data:Object;
      
      protected var m_rolloverTitle:ZwTextField;
      
      protected var m_stage:ZwTextField;
      
      protected var m_itemAmount:ZwTextField;
      
      protected var m_itemAmount2:ZwTextField;
      
      protected var m_building:CreditsBuilding = null;
      
      protected var m_creditsNeeded:Dictionary = new Dictionary();
      
      protected var m_levelReached:Boolean = false;
      
      protected var m_flyoutMc:MovieClip = null;
      
      public function StatesFlyoutSlot(element:DisplayObject, building:RewardCreditsBuilding)
      {
         super(element);
         this.m_building = building;
         this.m_flyoutMc = m_element.rollover_mc;
         this.m_flyoutMc.visible = false;
         this.m_rolloverTitle = new ZwTextField(this.m_flyoutMc["rollover_level_tf"]);
         addWidget(this.m_rolloverTitle);
         this.m_itemAmount = this.addWidget(new ZwTextField(this.m_flyoutMc["treats_tf"])) as ZwTextField;
         this.m_itemAmount2 = this.addWidget(new ZwTextField(this.m_flyoutMc["treats2_tf"])) as ZwTextField;
         for(var levelIndex:int = 0; this.m_flyoutMc.hasOwnProperty("buildable" + levelIndex + "_icon_mc"); levelIndex++)
         {
            this.m_flyoutMc["buildable" + levelIndex + "_icon_mc"].visible = false;
         }
         var textField:ZwTextField = new ZwTextField(m_element["level_tf"]);
         this.m_stage = this.addWidget(new ZwTextField(m_element.level_tf)) as ZwTextField;
         if(m_element.background_off_mc)
         {
            (m_element.background_off_mc as MovieClip).visible = true;
         }
         if(m_element.background_on_mc)
         {
            (m_element.background_on_mc as MovieClip).visible = false;
         }
         (m_element as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.rolloverCallback);
         (m_element as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.rolloutCallback);
      }
      
      override public function populate(data:Object) : void
      {
         var creditTypes:Array = null;
         var i:uint = 0;
         var type:String = null;
         var amountNeeded:Number = NaN;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_creditsNeeded = data.cost;
            this.m_rolloverTitle.text = this.m_data.title;
            this.m_stage.text = this.m_data.level;
            this.m_stage.visible = true;
            creditTypes = this.m_building.getCreditTypes();
            for(i = 0; i < creditTypes.length; i++)
            {
               type = creditTypes[i];
               amountNeeded = Number(this.m_data.cost[creditTypes[i]]);
               if(i == 0)
               {
                  this.m_itemAmount.text = amountNeeded.toString();
                  this.m_itemAmount.visible = true;
               }
               else if(i == 1)
               {
                  this.m_itemAmount2.text = amountNeeded.toString();
                  this.m_itemAmount2.visible = true;
                  break;
               }
            }
            this.updateState();
         }
      }
      
      public function updateState() : Boolean
      {
         if(this.m_levelReached == false)
         {
            this.m_levelReached = this.m_building.hasReachedLevel(this.m_creditsNeeded,this.m_building.getMultiTypeCredits(true));
            if(this.m_levelReached)
            {
               if(m_element.background_off_mc)
               {
                  (m_element.background_off_mc as MovieClip).visible = false;
               }
               if(m_element.background_on_mc)
               {
                  (m_element.background_on_mc as MovieClip).visible = true;
               }
            }
         }
         return this.m_levelReached;
      }
      
      protected function rolloverCallback(event:MouseEvent) : void
      {
         this.m_flyoutMc.visible = true;
         this.m_flyoutMc["buildable" + this.m_data.level + "_icon_mc"].visible = true;
      }
      
      protected function rolloutCallback(event:MouseEvent) : void
      {
         this.m_flyoutMc.visible = false;
         this.m_flyoutMc["buildable" + this.m_data.level + "_icon_mc"].visible = false;
      }
      
      override public function clearView() : void
      {
      }
   }
}

