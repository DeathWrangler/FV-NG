package Classes.crafting
{
   public class RecipeReward
   {
      
      public var recipeXp:Number = 0;
      
      public var playerXp:Number = 0;
      
      public var itemCode:String = null;
      
      public var sellQty:Number = 1;
      
      public var giftQty:Number = 1;
      
      public var fuel:Number = 1;
      
      public function RecipeReward()
      {
         super();
      }
      
      public static function fromXML(xml:XML) : RecipeReward
      {
         var reward:RecipeReward = new RecipeReward();
         reward.recipeXp = xml.hasOwnProperty("@recipeXp") ? Number(xml.@recipeXp) : 0;
         reward.playerXp = xml.hasOwnProperty("@playerXp") ? Number(xml.@playerXp) : 0;
         reward.itemCode = xml.hasOwnProperty("@itemCode") ? xml.@itemCode : null;
         reward.sellQty = xml.hasOwnProperty("@sellQty") ? Number(xml.@sellQty) : 0;
         reward.giftQty = xml.hasOwnProperty("@giftQty") ? Number(xml.@giftQty) : 0;
         reward.fuel = xml.hasOwnProperty("@fuel") ? Number(xml.@fuel) : 1;
         return reward;
      }
      
      public static function fromObject(obj:Object) : RecipeReward
      {
         var reward:RecipeReward = new RecipeReward();
         reward.recipeXp = obj.hasOwnProperty("recipeXp") ? Number(obj["recipeXp"]) : 0;
         reward.playerXp = obj.hasOwnProperty("playerXp") ? Number(obj["playerXp"]) : 0;
         reward.itemCode = obj.hasOwnProperty("itemCode") ? obj["itemCode"] : null;
         reward.sellQty = obj.hasOwnProperty("sellQty") ? Number(obj["sellQty"]) : 0;
         reward.giftQty = obj.hasOwnProperty("giftQty") ? Number(obj["giftQty"]) : 0;
         reward.fuel = obj.hasOwnProperty("fuel") ? Number(obj["fuel"]) : 1;
         return reward;
      }
   }
}

