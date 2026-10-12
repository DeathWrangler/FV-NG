package Classes
{
   import Classes.util.ZLocUtils;
   import Engine.Classes.WorldObject;
   import Managers.OffboardingManager;
   import com.greensock.TweenLite;
   
   public class SwapDecoration extends Decoration
   {
      
      private var m_forceComingSoon:Boolean = false;
      
      public function SwapDecoration(itemName:String = null)
      {
         super(itemName);
         var displayCountExperiementName:String = this.getItem().getSwapCountdownDisplayCountExperimentGate();
         if(displayCountExperiementName != null)
         {
            switch(Global.experimentManager.getExperimentVariant(displayCountExperiementName))
            {
               case 2:
               case 3:
                  this.m_forceComingSoon = false;
                  break;
               case 0:
               case 1:
               default:
                  this.m_forceComingSoon = true;
            }
         }
         else
         {
            this.m_forceComingSoon = false;
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.handleSwap();
      }
      
      public function handleSwap(forceRetestOfPrereqs:Boolean = false) : void
      {
         var fiveSeconds:Number = NaN;
         if(Global.player.isDataLoaded)
         {
            OffboardingManager.handleOffBoarding(this,false,false,this.onSwapComplete,forceRetestOfPrereqs);
         }
         else
         {
            fiveSeconds = 5;
            TweenLite.delayedCall(fiveSeconds,this.handleSwap,[forceRetestOfPrereqs]);
         }
      }
      
      public function onSwapComplete(oldWorldObj:WorldObject, newWorldObj:WorldObject) : void
      {
         var newBuilding:Building = null;
         if(Boolean(newWorldObj) && Boolean(newWorldObj as Building))
         {
            newBuilding = newWorldObj as Building;
            newBuilding.setState(newBuilding.STATE_BUILT);
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTipText:String = null;
         if(isHighlighted())
         {
            toolTipText = this.getItem().getSwapCountdownFriendlyTime("FarmGame:SwapDecorationTooltip_timeLeft_default","FarmGame:SwapDecorationTooltip_noTimeLeft_default",{"item":ZLocUtils.tk_pk_asTitle(getItemFriendlyName())},this.m_forceComingSoon);
            if(toolTipText)
            {
               setToolTip(toolTipText);
               updateToolTipPosition();
            }
            else
            {
               super.updateToolTipText();
            }
         }
      }
   }
}

