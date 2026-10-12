package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class ConstructionProgressionFObject extends BaseImageProgressionObject
   {
      
      public function ConstructionProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         var numConstructStates:Number = NaN;
         var numParts:int = 0;
         var numNeeded:int = 0;
         var partsPerState:Number = NaN;
         var imageNumber:Number = 1;
         var storageLevel:int = 1;
         var expand:IExpandComponent = m_owner.expand;
         if(expand)
         {
            storageLevel = int(expand.storageLevel);
            numConstructStates = 2;
            if(storageLevel <= 1)
            {
               numParts = m_owner.getPartsOnHand();
               numNeeded = expand.getTotalExpansionLimitCount();
               partsPerState = Math.floor(numNeeded / numConstructStates);
               imageNumber = Math.floor(numParts / partsPerState) + 1;
            }
            else
            {
               imageNumber = storageLevel + numConstructStates - 1;
            }
         }
         m_owner.setOverlayOverride(imageNumber,false);
      }
   }
}

