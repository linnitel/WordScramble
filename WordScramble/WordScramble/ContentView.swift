//
//  ContentView.swift
//  WordScramble
//
//  Created by Julia Martcenko on 26/01/2025.
//

import SwiftUI

struct ContentView: View {
	@State private var usedWords = [String]()
	@State private var rootWord = ""
	@State private var newWord = ""

	@State private var errorTitle = ""
	@State private var errorMessage = ""
	@State private var showErrorAlert = false

    var body: some View {
		NavigationStack {
			List {
				Section {
					TextField("Enter your word", text: $newWord)
						.textInputAutocapitalization(.never)
				}
				Section {
					ForEach(usedWords, id: \.self) { word in
						HStack {
							Image(systemName: "\(word.count).circle")
							Text(word)
						}
					}
				}
			}
			.navigationTitle(rootWord)
			.onSubmit(addNewWord)
			.onAppear(perform: startGame)
			.alert(errorTitle, isPresented: $showErrorAlert) {
				Button("OK") {}
			} message: {
					Text(errorMessage)
			}
		}
    }

	func addNewWord() {
		let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

		guard answer.count > 0 else { return }

		guard stringIsOriginal(word: answer) else {
			wodrError(title: "Word already used", massage: "Be more original!")
			return
		}

		guard isPossible(word: answer) else {
			wodrError(title: "Word not possible", massage: "You can't spell this word from '\(rootWord)'")
			return
		}

		guard isValid(word: answer) else {
			wodrError(title: "Word not recognized!", massage: "You can't just make them up, you know!")
			return
		}

		guard isShorter(word: answer) else {
			wodrError(title: "Word too short", massage: "Words must be at least three letters long.")
			return
		}

		withAnimation {
			usedWords.insert(answer, at: 0)
		}
		newWord = ""
	}

	func startGame() {
		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
			if let startWords = try? String(contentsOf: startWordsURL, encoding: .ascii) {
				let allWords = startWords.split(separator: "\n")
				rootWord = String(allWords.randomElement() ?? "silkworm")
				return
			}
		}

		fatalError("Could not load start.txt from the bundle!")
	}

	func stringIsOriginal(word: String) -> Bool {
		!usedWords.contains(word)
	}

	func isPossible(word: String) -> Bool {
		var tempWord = rootWord
			for letter in word {
				if let pos = tempWord.firstIndex(of: letter) {
					tempWord.remove(at: pos)
				} else {
				return false
			}
		}
		return true
	}

	func isValid(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledWords = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
		return misspelledWords.location == NSNotFound
	}

	func wodrError(title: String, massage: String) {
		errorTitle = title
		errorMessage = massage
		showErrorAlert = true
	}

	func isShorter(word: String) -> Bool {
		if word.count < 3 {
			return false
		}
		if word == rootWord {
			return false
		}
		return true
	}
}

#Preview {
    ContentView()
}
