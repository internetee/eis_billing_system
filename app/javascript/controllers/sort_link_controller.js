// app/javascript/controllers/debounce_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sort", "direction"]

    updateForm(event) {
      let searchParams = new URL(event.detail.url).searchParams

      this.sortTarget.value = searchParams.get("sort")
      this.directionTarget.value = searchParams.get("direction")
    }
}
