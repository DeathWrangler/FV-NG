package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.ChoiceDrivenManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   
   public class ContenderSlot extends ZwSlotFrame
   {
      
      protected var m_featureName:String;
      
      private const BONUSEXPIRY_TF:String = "bonusExpiry1_tf";
      
      private const HOVERINFO_MC:String = "hoverInfo_mc";
      
      private const HOVERINFOANIM_MC:String = "hoverInfoAnim_mc";
      
      private const BIOTEXT_TF:String = "bioText_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const NPCLOCKED_MC:String = "npcLocked_mc";
      
      private const NPCDEFEATED_MC:String = "npcDefeated_mc";
      
      private const NPCCURRENT_MC:String = "npcCurrent_mc";
      
      private const LOCK_MC:String = "lock_mc";
      
      private const DEFEATED_MC:String = "defeated_mc";
      
      private const SELECT_BT:String = "select_bt";
      
      private const BONUS_MC:String = "bonus_mc";
      
      private const TEXT_BONUS_EXPIRY:String = "_contender_bonus_expiry";
      
      protected var m_window:FarmWindow;
      
      private var m_selectButton:FarmAnimatedTextButton = null;
      
      protected var m_npcMC:MovieClip = null;
      
      protected var m_bioMC:MovieClip;
      
      protected var m_bioClip:MovieClip;
      
      private var m_bioFrame:ZwFrame;
      
      private var m_bioName:ZwTextField;
      
      private var m_bioText:ZwTextField;
      
      protected var m_data:Object = null;
      
      public function ContenderSlot(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_window = window;
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         if(m_element.hasOwnProperty(this.SELECT_BT))
         {
            addWidget(this.m_selectButton = new FarmAnimatedTextButton(m_element[this.SELECT_BT],"Select",this.onSelectButtonClick),false);
         }
         if(m_element.hasOwnProperty("hoverInfo_mc"))
         {
            this.m_bioMC = m_element.hoverInfo_mc;
            this.m_bioClip = m_element.hoverInfo_mc.hoverInfoAnim_mc;
            this.m_bioFrame = new ZwFrame(this.m_bioMC);
            addWidget(this.m_bioFrame,true);
            this.m_bioFrame.addWidget(this.m_bioName = new ZwTextField(this.m_bioClip.bioName_tf,""));
            this.m_bioFrame.addWidget(this.m_bioText = new ZwTextField(this.m_bioClip.bioText_tf,""));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var timeRemaining:Number = NaN;
         this.m_data = data;
         super.populate(data);
         if(ChoiceDrivenManager.getInstance(this.m_featureName).isFeaturePlayable())
         {
            switch(data.status)
            {
               case ChoiceDrivenManager.STAUS_CURRENT:
                  if(Boolean(data.isSelected) && Boolean(this.m_bioFrame))
                  {
                     this.m_bioName.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_contender_name_" + this.m_data.name);
                     this.m_bioText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_contender_onHover_" + this.m_data.name);
                     this.m_npcMC = m_element[this.NPCCURRENT_MC];
                     this.m_bioMC.visible = true;
                     this.m_bioMC.alpha = 0;
                     this.m_bioMC.mouseEnabled = false;
                     this.m_bioMC.mouseChildren = true;
                     this.m_npcMC.visible = true;
                     this.m_npcMC.alpha = 1;
                     this.m_npcMC.mouseEnabled = false;
                  }
                  this.m_npcMC = m_element[this.NPCCURRENT_MC];
                  m_element[this.NPCCURRENT_MC].visible = true;
                  m_element[this.NPCDEFEATED_MC].visible = false;
                  m_element[this.DEFEATED_MC].visible = false;
                  m_element[this.NPCLOCKED_MC].visible = false;
                  m_element[this.LOCK_MC].visible = false;
                  break;
               case ChoiceDrivenManager.STAUS_DEFEATED:
                  m_element[this.NPCCURRENT_MC].visible = false;
                  m_element[this.NPCDEFEATED_MC].visible = true;
                  m_element[this.DEFEATED_MC].visible = true;
                  m_element[this.NPCLOCKED_MC].visible = false;
                  m_element[this.LOCK_MC].visible = false;
                  break;
               case ChoiceDrivenManager.STAUS_IDLE:
                  m_element[this.NPCCURRENT_MC].visible = false;
                  m_element[this.NPCDEFEATED_MC].visible = false;
                  m_element[this.DEFEATED_MC].visible = false;
                  m_element[this.NPCLOCKED_MC].visible = true;
                  m_element[this.LOCK_MC].visible = true;
                  if(m_element.hasOwnProperty(this.BONUSEXPIRY_TF))
                  {
                     timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.m_data.bonusExpiry.toString()) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                     if(timeRemaining > 0)
                     {
                        addWidget(new ZwTextField(m_element[this.BONUSEXPIRY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_EXPIRY,{"days":HUD.getformattedTimeLeft(timeRemaining)})));
                     }
                     else
                     {
                        addWidget(new ZwTextField(m_element[this.BONUSEXPIRY_TF],"BONUS EXPIRED"));
                     }
                  }
            }
         }
         else
         {
            m_element[this.NPCCURRENT_MC].visible = true;
            m_element[this.NPCDEFEATED_MC].visible = false;
            m_element[this.DEFEATED_MC].visible = false;
            m_element[this.NPCLOCKED_MC].visible = false;
            m_element[this.LOCK_MC].visible = false;
            this.m_selectButton.visible = true;
            this.m_selectButton.enabled = !data.isSelected;
         }
      }
      
      private function onSelectButtonClick(event:Event) : void
      {
         ChoiceDrivenManager.getInstance(this.m_featureName).selectContenderReward(this.m_data.name);
         this.m_window.refreshWindow();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_bioFrame = null;
         this.m_bioMC = null;
         this.m_selectButton = null;
         this.m_npcMC = null;
      }
      
      private function onOver(evt:MouseEvent) : void
      {
         this.m_bioFrame.alpha = 1;
         TweenLite.to(this.m_bioClip,0.2,{"alpha":1});
         this.m_bioClip.stop();
         this.m_bioClip.visible = true;
         this.m_bioClip.gotoAndPlay(2);
      }
      
      private function onOut(evt:MouseEvent) : void
      {
         this.m_bioFrame.alpha = 0;
         this.m_bioClip.stop();
         TweenLite.to(this.m_bioClip,0.2,{"alpha":0});
      }
   }
}

