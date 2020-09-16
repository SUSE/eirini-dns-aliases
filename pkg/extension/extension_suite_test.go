package extension_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestEiriniExtension(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Extension test Suite")
}
