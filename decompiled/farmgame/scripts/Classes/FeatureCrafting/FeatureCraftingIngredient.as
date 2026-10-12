package Classes.FeatureCrafting
{
   public class FeatureCraftingIngredient extends FeatureCraftingRequiredGood
   {
      
      public function FeatureCraftingIngredient(system:FeatureCraftingSystem, config:XML)
      {
         var good:FeatureCraftingGood = system.getGoodByName(config.@name.toString());
         var numRequired:int = parseInt(config.@required.toString());
         super(system,good,numRequired);
      }
   }
}

